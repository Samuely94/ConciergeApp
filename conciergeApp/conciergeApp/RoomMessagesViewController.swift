//
//  RoomMessagesViewController.swift
//  conciergeApp
//
//  Created by Andrea Coldwell on 5/2/16.
//  Copyright © 2016 cs378. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class RoomMessagesViewController: JSQMessagesViewController {
    // sets the appearance for the different types of bubbles
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    let errorBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.redColor())
    let newBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let progressBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 247/255, green: 217/255, blue: 84/255, alpha: 1.0))
    let completeBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 54/255, green: 186/255, blue: 69/255, alpha: 1.0))
    
    // the messages to be displayed
    var messages = [JSQMessage]()
    
    // the messages set by the MessageViewController
    var userMessages:NSArray = []
    
    var currentUserID:String = "<not set>"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.updateFontSize()
    }
    
    // update the font size and reload messages when the iew appears
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateFontSize()
        self.reloadMessagesView()
    }
    
    func updateFontSize(){
        let currentUser = PFUser.currentUser()
        if (currentUser != nil){
            self.collectionView.collectionViewLayout.messageBubbleFont = UIFont .systemFontOfSize(currentUser!["messageFontSize"] as! CGFloat)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadMessagesView() {
        self.collectionView?.reloadData()
    }
    
    func getUserMessages(){
        // set the messages to be displayed for the current user
        self.messages = []
        // only display messages if the user has messages...
        if self.userMessages.count != 0 {
            // iterate through the users messages
            for message_index in 0...self.userMessages.count-1 {
                // get the current message from the user's messages
                let curMessage:NSDictionary = self.userMessages[message_index] as! NSDictionary
                // set some local variables
                var from:Int = -1
                var messageContent:String = "<not set>"
                var status:String = "<not set>"
                
                // gather all the current messages information
                for (key, value) in curMessage {
                    if(key as! String == "from"){
                        from = value as! Int
                    } else if (key as! String == "message"){
                        messageContent = value as! String
                    } else if (key as! String == "status"){
                        status = value as! String
                    }
                }
                // create the JSQMessage to be displayed
                let jMessage = JSQMessage(senderId: String(status), displayName: String(from), text: messageContent)
                self.messages += [jMessage]
            }
        }
        self.reloadMessagesView()
    }
    
    func setup() {
        // set the senderID to concierge
        self.senderId = "concierge"
        self.senderDisplayName = UIDevice.currentDevice().identifierForVendor?.UUIDString
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        // determines what type of bubble to display
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            return self.outgoingBubble
        case "error":
            return self.errorBubble
        case "new":
            self.newBubble
            return self.newBubble
        case "complete":
            return self.completeBubble
        case "progress":
            return self.progressBubble
        default:
            return self.incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    // controls what happens when the user presses send
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        // stores the message that was sent by the concierge on the backend
        PFCloud.callFunctionInBackground("sendMessageToGuest", withParameters: ["userId": self.currentUserID, "body": text]) {
            (response: AnyObject?, error: NSError?) -> Void in
            if let error = error{
                // records error to the console
                print(error)
            }
            else{
                // records a success if there is no error
                print("Message sent to Guest!")
            }
        }
        
        // creates the JSQMessage to be displayed
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages += [message]
        
        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
    }
}
