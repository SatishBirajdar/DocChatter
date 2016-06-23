//
//  TextChatViewController1.swift
//  DocChatter
//
//  Created by User on 2016-06-18.
//  Copyright © 2016 SBSoftwares (Satish Birajdar Softwares). All rights reserved.
//

import UIKit
import OpenTok
import JSQMessagesViewController

class TextChatViewController:  JSQMessagesViewController, OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate{
    
    var session : OTSession?
    var publisher : OTPublisher?
    var subscriber : OTSubscriber?
    
    // 2016-06-18 : setting chat bubble color.
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor(red:0.22, green:0.94, blue:0.37, alpha:1.0))
    
    // 2016-06-18 : initializing list of messages
    var messages = [JSQMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Text Chat"
        
        // Do any additional setup after loading the view, typically from a nib.
        print("TextChatViewController loaded ", ApiKey , " SessionID ",SessionID)
        session = OTSession(apiKey: ApiKey, sessionId: SessionID, delegate: self)
        
        // 2016-06-18 : connect to the Server provided session details.
        doConnect()
        
        // 2016-06-18 : identify the Sender device.
        self.setup()
        
        // 2016-06-18 : add demo messages to the Message List.
        self.addDemoMessages()
    }
    
    
    // 2016-06-18 : fetch the new data recieved from Server
    func session(session: OTSession!, receivedSignalType type: String!, fromConnection connection: OTConnection!, withString string: String!) {
        
        // 2016-06-18 : prevent recieving messages from the same device.
        if(!(connection.connectionId == session.connection.connectionId))
        {
            print("Recieved String is ",string)
            let sender = "Server" 
            let messageContent = string
            let message = JSQMessage(senderId: sender, displayName: sender, text: messageContent)
            self.messages += [message]
            
            self.reloadMessagesView()
            
            // 2016-06-18 : scroll to the bottom when new message is recieved.
            let item = self.collectionView(self.collectionView!, numberOfItemsInSection: 0) - 1
            let lastItemIndex = NSIndexPath(forItem: item, inSection: 0)
            self.collectionView?.scrollToItemAtIndexPath(lastItemIndex, atScrollPosition: UICollectionViewScrollPosition.Bottom, animated: true)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        // As the view comes into the foreground, begin the connection process.
        // doConnect()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // OpenTok Methods
    
    /**
    * Asynchronously begins the session connect process. Some time later, we will
    * expect a delegate method to call us back with the results of this action.
    */
    func doConnect() {
        if let session = self.session {
            var maybeError : OTError?
            session.connectWithToken(Token, error: &maybeError)
            if let error = maybeError {
                showAlert(error.localizedDescription)
            }
        }
    }
    
    // OTSession delegate callbacks
    
    func sessionDidConnect(session: OTSession) {
        NSLog("sessionDidConnect (\(session.sessionId))")
        
        // We have successfully connected, now instantiate a publisher and
        // begin pushing A/V streams into OpenTok.
        //        doPublish()
    }
    
    func sessionDidDisconnect(session : OTSession) {
        NSLog("Session disconnected (\( session.sessionId))")
    }
    
    func session(session: OTSession, streamCreated stream: OTStream) {
        NSLog("session streamCreated (\(stream.streamId))")
        
        // if NO == subscribeToSelf): Begin subscribing to a stream we
        // have seen on the OpenTok session.
        //        if subscriber == nil && !SubscribeToSelf {
        //            doSubscribe(stream)
        //        }
    }
    
    func session(session: OTSession, streamDestroyed stream: OTStream) {
        NSLog("session streamCreated (\(stream.streamId))")
        
        //        if subscriber?.stream.streamId == stream.streamId {
        //            doUnsubscribe()
        //        }
    }
    
    func session(session: OTSession, connectionCreated connection : OTConnection) {
        NSLog("session connectionCreated (\(connection.connectionId))")
    }
    
    func session(session: OTSession, connectionDestroyed connection : OTConnection) {
        NSLog("session connectionDestroyed (\(connection.connectionId))")
    }
    
    func session(session: OTSession, didFailWithError error: OTError) {
        NSLog("session didFailWithError (%@)", error)
    }
    
    // OTSubscriber delegate callbacks
    
    func subscriberDidConnectToStream(subscriberKit: OTSubscriberKit) {
        NSLog("subscriberDidConnectToStream (\(subscriberKit))")
        if let view = subscriber?.view {
            view.frame =  CGRect(x: 0.0, y: videoHeight, width: videoWidth, height: videoHeight)
            //            self.view.addSubview(view)
        }
    }
    
    func subscriber(subscriber: OTSubscriberKit, didFailWithError error : OTError) {
        NSLog("subscriber %@ didFailWithError %@", subscriber.stream.streamId, error)
    }
    
    // MARK: - OTPublisher delegate callbacks
    
    func publisher(publisher: OTPublisherKit, streamCreated stream: OTStream) {
        NSLog("publisher streamCreated %@", stream)
        
        // Step 3b: (if YES == subscribeToSelf): Our own publisher is now visible to
        // all participants in the OpenTok session. We will attempt to subscribe to
        // our own stream. Expect to see a slight delay in the subscriber video and
        // an echo of the audio coming from the device microphone.
        //        if subscriber == nil && SubscribeToSelf {
        //            doSubscribe(stream)
        //        }
    }

    func publisher(publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        NSLog("publisher streamDestroyed %@", stream)
        
        //        if subscriber?.stream.streamId == stream.streamId {
        //            doUnsubscribe()
        //        }
    }
    
    func publisher(publisher: OTPublisherKit, didFailWithError error: OTError) {
        NSLog("publisher didFailWithError %@", error)
    }
    
    // Helpers
    
    func showAlert(message: String) {
        // show alertview on main UI
        dispatch_async(dispatch_get_main_queue()) {
            //            let alert = UIAlertController(title: "OTError", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            
            
            // create the alert
            let alert = UIAlertController(title: "OTError", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            
            // add the actions (button)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
            
            // show the alert
            self.presentViewController(alert, animated: true, completion: nil)
            //            (title: "OTError", message: message, delegate: nil, cancelButtonTitle: "OK")
        }
    }


    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 2016-06-18 : reload the Message List View
    func reloadMessagesView() {
        self.collectionView?.reloadData()
    }

    // 2016-06-18 : add demo messages to the Message List View
    func addDemoMessages() {
        for i in 1...10 {
            let sender = (i%2 == 0) ? "Server" : self.senderId
            let messageContent = "Message nr. \(i)"
            let message = JSQMessage(senderId: sender, displayName: sender, text: messageContent)
            self.messages += [message]
        }
        self.reloadMessagesView()
    }
    
    // 2016-06-18 : identify the Sender device.
    func setup() {
        self.senderId = UIDevice.currentDevice().identifierForVendor?.UUIDString
        self.senderDisplayName = UIDevice.currentDevice().identifierForVendor?.UUIDString
    }
    
    // 2016-06-18 : identify the Messages count.
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    // 2016-06-18 : identify the Message Data at IndexPath.
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    // 2016-06-18 : delete the Message Data at IndexPath.
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.row)
    }
    
    // 2016-06-18 : identify the sender of the Message and select the chat bubble accordingly.
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }
    
    // 2016-06-18 : identify avatar for the Message Data at IndexPath.
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    // 2016-06-18 : action method for Send Button.
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages += [message]
        self.finishSendingMessage()

        if let session = self.session {
            var maybeError : OTError?; session.signalWithType(nil, string: message.text, connection: nil, error: &maybeError)
            
            if let error = maybeError
            {
                print("signal not sent with error ", error)
            }
            else
            {
                print("signal sent")
            }
        }
        
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
    }
    
}




