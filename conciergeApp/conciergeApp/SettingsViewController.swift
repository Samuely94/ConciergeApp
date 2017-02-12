//
//  SettingsViewController.swift
//  conciergeApp
//
//  Created by Andrea Coldwell on 3/30/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController, UITextFieldDelegate {
    // for the change password alert controller
    var alertController:UIAlertController? = nil
    
    @IBOutlet weak var userMessages: UILabel!
    var settings = [NSManagedObject]()
    
    @IBOutlet weak var numDays: UILabel!
    @IBOutlet weak var fontSize: UILabel!
    
    @IBOutlet weak var deleteAfterCheckout: UISwitch!
    
    @IBOutlet weak var addDaysBtn: UIButton!
    @IBOutlet weak var subtractDaysBtn: UIButton!
    
    @IBOutlet weak var addFontSizeBtn: UIButton!
    @IBOutlet weak var subtractFontSizeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // here is where we display initial view
    @IBAction func logOutUser(sender: AnyObject) {
        print("Logging user out")
        PFUser.logOut()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName:"GlobalSettings")
        
        var fetchedResults:[NSManagedObject]? = nil
        
        do {
            try fetchedResults = managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
        } catch {
            // what to do if an error occurs?
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        if var results = fetchedResults {
            if results.count == 0 {
                let entity =  NSEntityDescription.entityForName("GlobalSettings", inManagedObjectContext: managedContext)
                
                // create a global entity
                // sets the default values if nothing has been set
                let settings = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
                settings.setValue(false, forKey: "autoCheckoutDelete")
                settings.setValue(3, forKey: "deleteMessagesAfter")
                
                results.append(settings)
            }
            self.deleteAfterCheckout.setOn(results[0].valueForKey("autoCheckoutDelete") as! Bool, animated: true)
            self.numDays.text! = String(results[0].valueForKey("deleteMessagesAfter")!)
            if results[0].valueForKey("autoCheckoutDelete") as! Bool {
                self.numDays.enabled = false
                self.addDaysBtn.enabled = false
                self.subtractDaysBtn.enabled = false
            } else {
                self.updateDaysButtons(results[0].valueForKey("deleteMessagesAfter") as! Int)
            }
            settings = results
        } else {
            print("Could not fetch")
        }
        
        //save the data
        do {
            try managedContext.save()
        } catch {
            // what to do if an error occurs?
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        // display the font size
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
            if let fontSize = currentUser!["messageFontSize"] as? Int {
                self.fontSize.text = String(fontSize)
                if (fontSize == 12){
                    self.subtractFontSizeBtn.enabled = false
                    self.addFontSizeBtn.enabled = true
                }
                if (fontSize == 18) {
                    self.subtractFontSizeBtn.enabled = true
                    self.addFontSizeBtn.enabled = false
                }
                
            } else {
                //need to set messageFontSize
                currentUser!["messageFontSize"] = 14
                currentUser!.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        // The object has been saved.
                        self.fontSize.text = "14"
                    } else {
                        // There was a problem, check error.description
                        print(error!.description)
                    }
                }
                
            }
        } else {
            print("Nothing")
            // Show the signup or login screen
        }
        
    }
    
    @IBAction func btnAddDays(sender: AnyObject) {
        if self.settings[0].valueForKey("autoCheckoutDelete") as! Bool == false {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            let managedContext = appDelegate.managedObjectContext
        
            var days = self.settings[0].valueForKey("deleteMessagesAfter") as! Int
            if days < 5 {
                days = days + 1
                self.settings[0].setValue(days, forKey: "deleteMessagesAfter")
            }

            dispatch_async(dispatch_get_main_queue()) {
                self.numDays.text! = String(days)
            }
        
            do {
                try managedContext.save()
            } catch {
                // what to do if an error occurs?
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
            
            self.updateDaysButtons(days)
        }
    }
    
    @IBAction func btnSubtractDays(sender: AnyObject) {
        if self.settings[0].valueForKey("autoCheckoutDelete") as! Bool == false {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
            let managedContext = appDelegate.managedObjectContext
        
            var days = settings[0].valueForKey("deleteMessagesAfter") as! Int
            // can only subtract days if greater than 0
            if days > 1 {
                days = days - 1
                settings[0].setValue(days, forKey: "deleteMessagesAfter")
            }
        
            dispatch_async(dispatch_get_main_queue()) {
                self.numDays.text! = String(days)
            }
        
            do {
                try managedContext.save()
            } catch {
                // what to do if an error occurs?
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
            
            self.updateDaysButtons(days)
        }

    }

    @IBAction func btnSwitchAutoCheckout(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let autoCheckout:Bool = settings[0].valueForKey("autoCheckoutDelete") as! Bool
        
        self.settings[0].setValue(!autoCheckout, forKey: "autoCheckoutDelete")
        
        dispatch_async(dispatch_get_main_queue()) {
            self.deleteAfterCheckout.setOn(!autoCheckout, animated: true)
            if self.settings[0].valueForKey("autoCheckoutDelete") as! Bool {
                self.numDays.enabled = false
                self.addDaysBtn.enabled = false
                self.subtractDaysBtn.enabled = false
            } else {
                self.numDays.enabled = true
                self.addDaysBtn.enabled = true
                self.subtractDaysBtn.enabled = true
            }
        }
        
        do {
            try managedContext.save()
        } catch {
            // what to do if an error occurs?
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        self.updateDaysButtons(self.settings[0].valueForKey("deleteMessagesAfter") as! Int)
    }
    
    func updateDaysButtons(days: Int){
        dispatch_async(dispatch_get_main_queue()) {
            if self.deleteAfterCheckout.on {
                self.numDays.enabled = false
                self.addDaysBtn.enabled = false
                self.subtractDaysBtn.enabled = false
            } else {
                if days == 5 {
                    self.numDays.enabled = true
                    self.addDaysBtn.enabled = false
                    self.subtractDaysBtn.enabled = true
                } else if days == 1 {
                    self.numDays.enabled = true
                    self.addDaysBtn.enabled = true
                    self.subtractDaysBtn.enabled = false
                } else {
                    self.numDays.enabled = true
                    self.addDaysBtn.enabled = true
                    self.subtractDaysBtn.enabled = true
                }
            }
        }
    }
    
    @IBAction func btnAddFontSize(sender: AnyObject) {
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
            var userFontSize = currentUser!["messageFontSize"] as! Int
            if userFontSize < 18 {
                userFontSize += 1
                currentUser!["messageFontSize"] = userFontSize
                currentUser!.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        
                        // The object has been saved.
                        print("saved add font size")
                    } else {
                        // There was a problem, check error.description
                        print(error!.description)
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.fontSize.text = String(userFontSize)
                }
            }
            self.updateFontSizeButtons(userFontSize)
        }

    }

    
    @IBAction func btnSubtractFontSize(sender: AnyObject) {
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
            var userFontSize = currentUser!["messageFontSize"] as! Int
            if userFontSize > 12 {
                userFontSize -= 1
                currentUser!["messageFontSize"] = userFontSize
                currentUser!.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        
                        // The object has been saved.
                        print("saved subtract font size")
                    } else {
                        // There was a problem, check error.description
                        print(error!.description)
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.fontSize.text = String(userFontSize)
                }
                
            }
            self.updateFontSizeButtons(userFontSize)
        }
    }
    
    func updateFontSizeButtons(curSize: Int){
        dispatch_async(dispatch_get_main_queue()) {
            if curSize == 18 {
                self.addFontSizeBtn.enabled = false
                self.subtractFontSizeBtn.enabled = true
            } else if curSize == 12 {
                self.addFontSizeBtn.enabled = true
                self.subtractFontSizeBtn.enabled = false
            } else {
                self.addFontSizeBtn.enabled = true
                self.subtractFontSizeBtn.enabled = true
            }
        }
    }
    
    @IBAction func changePasswordBtn(sender: AnyObject) {
        PFUser.requestPasswordResetForEmailInBackground(PFUser.currentUser()!["email"] as! String)
        
        self.alertController = UIAlertController(title: "Password Changed!", message: "You have been sent an email to reset your password.", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction) in
            print("You have been sent an email to reset your password.")
        }
        self.alertController!.addAction(okAction)
        self.presentViewController(self.alertController!, animated: true, completion:nil)
    }
}
