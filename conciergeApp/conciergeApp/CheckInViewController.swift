//
//  CheckInViewController.swift
//  conciergeApp
//
//  Created by Andrea Coldwell on 3/30/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit

class CheckInViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    var alertController:UIAlertController? = nil
    
    //instantiate variables
    @IBOutlet weak var newRoomNumber: UITextField!
    
    @IBOutlet weak var newName: UITextField!
    
    @IBOutlet weak var newPhoneNumber: UITextField!
    
    @IBOutlet weak var newCheckout: UITextField!
   
    @IBOutlet weak var myDatePicker: UIDatePicker!
    
    @IBOutlet weak var message: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
   
    @IBOutlet weak var scrollView: UIScrollView!
  
    @IBOutlet weak var contentView: UIView!
    
    @IBAction func changeDate(sender: AnyObject) {
    }
    
    // list of guests
    var guests: [PFObject] = [PFObject]()
    var duplicates: [PFObject] = [PFObject]()
    
    weak var activeField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // queries all the guests
        let query = PFQuery(className: "Guest")
        query.whereKey("isCheckedOut", equalTo: false)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        self.guests.append(object)
                    }
                    self.tableView.reloadData()
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.newRoomNumber.delegate = self
        self.newName.delegate = self
        self.newPhoneNumber.delegate = self
        
        // get the current date
        let currentDate = NSDate()
        myDatePicker.datePickerMode = UIDatePickerMode.Date
        myDatePicker.minimumDate = currentDate
        myDatePicker.date = currentDate
        
        self.tableView.reloadData()
        
        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CheckInViewController.keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CheckInViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.activeField = nil
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.activeField = textField
    }
    
    func keyboardDidShow(notification: NSNotification) {
        if let activeField = self.activeField, keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            var aRect = self.view.frame
            aRect.size.height -= keyboardSize.size.height
            if (!CGRectContainsPoint(aRect, activeField.frame.origin)) {
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets = UIEdgeInsetsZero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // loads the data model
    func loadDataModel() {
        self.guests = [PFObject]()
        let query = PFQuery(className: "Guest")
        query.whereKey("isCheckedOut", equalTo: false)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        self.guests.append(object)
                    }
                    self.tableView.reloadData()
                }
            }
            else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
    }
    
    // check to see if the datePicker value changed
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.guests.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        let guest = self.guests[indexPath.row]
        
        let guestCell = tableView.dequeueReusableCellWithIdentifier("guestCell", forIndexPath: indexPath) as! (GuestTableViewCell)
        guestCell.roomNumber.text! = guest["roomNumber"] as! String
        guestCell.name.text! = guest["name"] as! String
        guestCell.phoneNumber.text! = guest["phoneNumber"] as! String
        guestCell.checkoutDate.text! = guest["checkoutDate"] as! String
        guestCell.deleteGuest.tag = indexPath.row
        cell = guestCell
        return cell!
    }
   
    // saves the guest on click
    @IBAction func btnSaveGuest(sender: AnyObject) {
        // checks the field parameters
        if !newRoomNumber.text!.isEmpty && !newName.text!.isEmpty && !newPhoneNumber.text!.isEmpty {
            self.duplicates = [PFObject]()
            let pquery = PFQuery(className: "Guest")
            pquery.whereKey("isCheckedOut", equalTo: false)
            pquery.whereKey("phoneNumber", equalTo: newPhoneNumber.text!)
            pquery.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                if let objects = objects {
                    for object in objects {
                        self.duplicates.append(object)
                    }
                    
                    if !self.duplicates.isEmpty{
                        self.alertController = UIAlertController(title: "Phone number already being used!", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction) in
                            print("Guest Checkin error")
                        }
                        self.alertController!.addAction(okAction)
                        self.presentViewController(self.alertController!, animated: true, completion:nil)
                        self.newRoomNumber.text! = ""
                        self.newName.text! = ""
                        self.newPhoneNumber.text! = ""
                    }
                    else {
                        self.message.text! = ""
                        let guest = PFObject(className: "Guest")
                        guest["roomNumber"] = self.newRoomNumber.text!
                        guest["name"] = self.newName.text!
                        guest["phoneNumber"] = self.newPhoneNumber.text!
                        guest["isCheckedOut"] = false
                        guest["messages"] = []
                        
                        let phoneNumber = guest["phoneNumber"]

                        
                        var phone = self.newPhoneNumber.text!
                        phone = phone.stringByReplacingOccurrencesOfString("-", withString: "")
                        phone = phone.stringByReplacingOccurrencesOfString("(", withString: "")
                        phone = phone.stringByReplacingOccurrencesOfString(")", withString: "")
                        phone = phone.stringByReplacingOccurrencesOfString(".", withString: "")
                        
                        let name = self.newName.text!
                        let dateFormatter = NSDateFormatter()//3
                        let theDateFormat = NSDateFormatterStyle.ShortStyle //5
                        
                        dateFormatter.dateStyle = theDateFormat//8
                        guest["checkoutDate"] = dateFormatter.stringFromDate(self.myDatePicker.date)
                        
                        guest.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            if let error = error {
                                // alert if there is an error
                                let errorString = error.userInfo["error"] as? String
                                print(errorString)
                                self.alertController = UIAlertController(title: "Guest check in error...", message: "Could not sign up at this time. Check your internet connection and try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                                let okAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction) in
                                    print("Guest Checkin error")
                                }
                                self.alertController!.addAction(okAction)
                                self.presentViewController(self.alertController!, animated: true, completion:nil)
                            }
                            else {
                                // notify the user they were successfully checked in
                                self.alertController = UIAlertController(title: "Guest successfully checked in!", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action:UIAlertAction) in
                                    //self.dismissViewControllerAnimated(false, completion: nil)
                                    self.loadDataModel()
                                    self.tableView.reloadData()
                                    NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
                                    self.newRoomNumber.text! = ""
                                    self.newName.text! = ""
                                    self.newPhoneNumber.text! = ""
                                    
                                }
                                self.alertController!.addAction(okAction)
                                self.presentViewController(self.alertController!, animated: true, completion:nil)
                                self.message.text! = ""
                                
                                let query = PFQuery(className: "Guest")
                                query.whereKey("phoneNumber", equalTo: phoneNumber)
                                query.whereKey("isCheckedOut", equalTo: false)
                                query.findObjectsInBackgroundWithBlock {
                                    (objects: [PFObject]?, error: NSError?) -> Void in
                                    if error == nil {
                                        if let objects = objects {
                                            let cur_object = objects.first!
                                            print(cur_object)
                                            PFCloud.callFunctionInBackground("sendMessage", withParameters: ["phone": phone, "name": name, "userId": cur_object.objectId!]) {
                                                (response: AnyObject?, error: NSError?) -> Void in
                                                if let error = error{
                                                    print(error)
                                                }
                                                else{
                                                    print("Message Sent!")
                                                }
                                            }
                                        }
                                    } else {
                                        print("Error: \(error!) \(error!.userInfo)")
                                    }
                                }
                                
                                
                            }
                            //saved
                        }
                    }
                }
            }
        }
        else {
            // have an alert that tells user to fill in all the required data
            self.alertController = UIAlertController(title: "Error", message: "You need to fill in all required fields for a new guest!", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction) in
                print("You need to fill in all required fields for a new guest!")
            }
            self.alertController!.addAction(okAction)
            self.presentViewController(self.alertController!, animated: true, completion:nil)
        }
    }
    
    // deletes the guest when the button is clicked
    @IBAction func deleteGuest(sender: AnyObject) {
        let BtnSender : UIButton = sender as! UIButton
        let guestincell = self.guests[BtnSender.tag]
        
        guestincell["isCheckedOut"] = true
        // delete the user on the server
        guestincell.deleteInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if let error = error {
                let errorString = error.userInfo["error"] as? String
                
                // add an error alert
                self.alertController = UIAlertController(title: "Could not delete..", message: "Could not delete guest at this time. Check your internet connection and try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction) in
                    print(errorString)
                }
                self.alertController!.addAction(okAction)
                self.presentViewController(self.alertController!, animated: true, completion:nil)
            }
            else {
                // add an alert to let the concierge know the user was deleted!
                self.alertController = UIAlertController(title: "Deleted Guest", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction) in
                    self.loadDataModel()
                    self.tableView.reloadData()
                    NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
                }
                self.alertController!.addAction(okAction)
                self.presentViewController(self.alertController!, animated: true, completion:nil)
            }
        }
    }
}
