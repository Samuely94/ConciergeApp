//
//  SignUpViewController.swift
//  conciergeApp
//
//  Created by samuel on 3/21/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import CoreData

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var badgeNumber: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordVerify: UITextField!
    @IBOutlet weak var message: UILabel!
   
    var concierges = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstName.delegate = self
        lastName.delegate = self
        badgeNumber.delegate = self
        email.delegate = self
        password.delegate = self
        passwordVerify.delegate = self
        self.view.addBackground()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // saves the Conierge to the backend
    func saveConcierge(firstName: String, lastName: String, badgeNumber: String, password: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entityForName("Concierge", inManagedObjectContext: managedContext)
        let concierge = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        // set the values for the convierge
        concierge.setValue(firstName, forKey: "firstName")
        concierge.setValue(lastName, forKey: "lastName")
        concierge.setValue(badgeNumber, forKey: "badgeNumber")
        concierge.setValue(password, forKey: "password")
        concierge.setValue(14.0, forKey: "messageFontSize")
        
        do {
            try managedContext.save()
            concierges.append(concierge)
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    static let sharedInstance = SignUpViewController()
    func getConcierge() -> [NSManagedObject] {
        return concierges
    }
    
    @IBAction func BtnSaveClicked(sender: AnyObject) {
        // checks that the fields are not empty
        if !firstName.text!.isEmpty && !lastName.text!.isEmpty && !badgeNumber.text!.isEmpty && !email.text!.isEmpty && !password.text!.isEmpty && !passwordVerify.text!.isEmpty {
            // verifies the passwords are equal
            if password.text! == passwordVerify.text! {
                let user = PFUser()
                
                user.username = badgeNumber.text!
                user.password = password.text!
                user["firstName"] = firstName.text!
                user["lastName"] = lastName.text!
                user["email"] = email.text!
                user["messageFontSize"] = 14
                
                // signs the user up
                user.signUpInBackgroundWithBlock {
                    (succeeded: Bool, error: NSError?) -> Void in
                    if let error = error {
                        let errorString = error.userInfo["error"] as? String
                        print(errorString)
                        let alert = UIAlertController(title: "Can not sign up", message: "Could not sign up at this time. Check your internet connection and try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    else {
                        self.message.text! = ""
                        let alert = UIAlertController(title: "Thanks for signing up!", message: "Use your badge number and password to log in", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                            self.dismissViewControllerAnimated(false, completion: nil)
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
            else {
                message.text! = "Passwords don't match!"
            }
        }
        else {
            message.text! = "You must fill in all required fields!"
        }
    
    
    }
}
