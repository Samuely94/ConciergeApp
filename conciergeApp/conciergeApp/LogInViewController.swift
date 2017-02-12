//
//  LogInViewController.swift
//  conciergeApp
//
//  Created by samuel on 3/21/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import CoreData

class LogInViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var message: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addBackground()
        
        self.username.delegate = self
        self.password.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // login in
    @IBAction func BtnClickLogin(sender: AnyObject) {
        login()
    }
    
    // logs the user in using parse
    func login() {
        PFUser.logInWithUsernameInBackground(username.text!, password: password.text!) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                // Successful Login
                self.performSegueWithIdentifier("MessagingViewController", sender:self)
            } else {
                // The login failed. Check error to see why.
                let alert = UIAlertController(title: "Error", message: "Log in credentials not valid", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)

            }
        }
    }
    
    // when the user clicks enter, log the user in
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        login()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}
