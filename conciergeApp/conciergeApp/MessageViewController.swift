//
//  MessageViewController.swift
//  conciergeApp
//
//  Created by Andrea Coldwell on 3/30/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import Foundation

class MessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // controls the status filtering feature
    @IBOutlet weak var statusSC: UISegmentedControl!
    
    // how we set information in the RoomMessageViewController
    private var embeddedViewController: RoomMessagesViewController!
    
    // global variable that determines which subGuests list to display
    private var statusSetting:String!
    
    // global timer variable
    private var timer:NSTimer!
    
    @IBOutlet weak var tempMessage: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    // list of all the guests
    var guests: [PFObject] = [PFObject]()
    
    // sub list of guests displayed depending on filtering
    var subGuests:[PFObject] = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Messages"
        self.statusSetting = "all"
    }
    
    // stop the timer when the view disappears
    override func viewDidDisappear(animated: Bool) {
        self.timer.invalidate()
    }
    
    // load the inital user data and start the timer to poll for messages
    // when the view appears
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // Do any additional setup after loading the view.
        // load the inital user data
        self.guests = [PFObject]()
        
        // get the array of Guests
        let query = PFQuery(className: "Guest")
        // only retrieve guests who are checked in
        query.whereKey("isCheckedOut", equalTo: false)
        // order the guests by the most recently updated
        query.orderByDescending("updatedAt")
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    // add the objects to the guest list
                    for object in objects {
                        self.guests.append(object)
                    }
                    // create the sublists
                    self.createSubList()
                    // reload the data
                    self.tableView.reloadData()
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessageViewController.loadList(_:)),name:"load", object: nil)
        
        // set the timer to check for messages every 3 seconds
        self.timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(MessageViewController.loadList(_:)), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // load list : a function that checks to see if new data is available to display
    func loadList(notification: NSNotification){
        // get the array of Guests
        let query = PFQuery(className: "Guest")
        // make sure the guest is checked in
        query.whereKey("isCheckedOut", equalTo: false)
        // order the data by most up to date
        query.orderByDescending("updatedAt")
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    if self.guests.count == 0 {
                        for object in objects {
                            self.guests.append(object)
                        }
                        // create the sublists
                        self.createSubList()
                        // reload the data
                        self.tableView.reloadData()
                    } else if objects[0].updatedAt?.compare(self.guests[0].updatedAt!) != NSComparisonResult.OrderedSame {
                        // checks to see if the most recent guests has changed, if so, update the guest list
                        self.guests = [PFObject]()
                        for object in objects {
                            self.guests.append(object)
                        }
                        // assign the controller to show the most recent user's messages
                        self.embeddedViewController.userMessages = self.guests[0]["messages"] as! NSArray
                        self.embeddedViewController.currentUserID = self.guests[0].objectId!
                        self.embeddedViewController.getUserMessages()
                        self.createSubList()
                        self.tableView.reloadData()
                    } else {
                        print("The guest list does not need to be updated.")
                        //print("********* in the else \(objects[0]) and the guest is: \(self.guests[0])")
                    }
                    
                } else {
                    print("guest list now: \(self.guests)")
                }
            }
            else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows for the current guest list
        return self.subGuests.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        // get the guest that was clicked
        let guest = self.subGuests[indexPath.row]
        let guestCell = tableView.dequeueReusableCellWithIdentifier("cellid", forIndexPath: indexPath) as! MessageTableViewCell
        
        guestCell.guestName.text! = guest["name"] as! String
        guestCell.roomNumber.text! = guest["roomNumber"] as! String
        cell = guestCell
        
        return cell!
    }

    // slides the keyboard down if done editing
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // shows the correct message depending on which cell is selected
        let guest = self.subGuests[indexPath.row]
        if(guest["messages"] == nil){
            // if there are no messages, display nothing
            self.embeddedViewController.userMessages = []
            self.embeddedViewController.currentUserID = guest.objectId!
            self.embeddedViewController.getUserMessages()
        } else {
            self.embeddedViewController.userMessages = guest["messages"] as! NSArray
            self.embeddedViewController.currentUserID = guest.objectId!
            self.embeddedViewController.getUserMessages()
        }
    }
    
    // a method that creates the sub lists that show when a segmented view is shown
    func createSubList(){
        self.subGuests = [PFObject]()
        // iterate through the guest list
        for g in self.guests {
            // if all is selected, all all the guests
            if(self.statusSetting == "all"){
                self.subGuests.append(g)
            } else if(g["lastStatus"] as? String == self.statusSetting){
                // if the status is equal to the statusSetting that was selected
                self.subGuests.append(g)
            }
        }
        // if the subguests is 0 then display nothing, otherwise display the top guest's messages
        if self.subGuests.count == 0{
            self.embeddedViewController.userMessages = []
            self.embeddedViewController.currentUserID = "<not set>"
            self.embeddedViewController.getUserMessages()
        } else {
            self.embeddedViewController.userMessages = self.subGuests[0]["messages"] as! NSArray
            self.embeddedViewController.currentUserID = self.subGuests[0].objectId!
            self.embeddedViewController.getUserMessages()
        }
    }
    
    // controls what happens when the segmented controller is clicked
    @IBAction func statusSegmentedControllerAction(sender: AnyObject) {
        if(self.statusSC.selectedSegmentIndex == 0){
            self.statusSetting = "all"
        } else if (self.statusSC.selectedSegmentIndex == 1) {
            self.statusSetting = "new"
        } else if (self.statusSC.selectedSegmentIndex == 2) {
            self.statusSetting = "progress"
        } else if (self.statusSC.selectedSegmentIndex == 3) {
            self.statusSetting = "complete"
        }
        self.createSubList()
        self.tableView.reloadData()
    }
    
    // controls the container embeded in the message view controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? RoomMessagesViewController
            where segue.identifier == "EmbedSegue" {
                self.embeddedViewController = vc
        }
    }
}
