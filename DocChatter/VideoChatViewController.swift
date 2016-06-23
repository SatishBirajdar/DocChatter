//
//  VideoChatViewController.swift
//  DocChatter
//
//  Created by User on 2016-06-19.
//  Copyright © 2016 SBSoftwares (Satish Birajdar Softwares). All rights reserved.
//


import UIKit
import OpenTok

let videoWidth : CGFloat = 320
let videoHeight : CGFloat = 240

// 2016-06-19 : OpenTok API key
let ApiKey = "45608182"
// 2016-06-19 : generated session ID
let SessionID = "1_MX40NTYwODE4Mn5-MTQ2NjEyMjY0Mzc4N351Yk1IUWZzdjJyT0QzcDRjelN3cUdFOHJ-fg"
// 2016-06-19 : generated token
let Token = "T1==cGFydG5lcl9pZD00NTYwODE4MiZzaWc9ZDMyOTUzZGExMDg3YTNkYjg4OWFhYWQwYzIyNjhhOGUzMTVmOTI1MzpzZXNzaW9uX2lkPTFfTVg0ME5UWXdPREU0TW41LU1UUTJOakV5TWpZME16YzROMzUxWWsxSVVXWnpkakp5VDBRemNEUmplbE4zY1VkRk9ISi1mZyZjcmVhdGVfdGltZT0xNDY2MTIyNjY1Jm5vbmNlPTAuMDE1ODM4MDU1ODcxNDI3MDYmcm9sZT1wdWJsaXNoZXImZXhwaXJlX3RpbWU9MTQ2ODcxNDgwNA=="

// 2016-06-19 : Change to YES to subscribe to your own stream.
let SubscribeToSelf = false

class VideoChatViewController: UIViewController, OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var session : OTSession?
    var publisher : OTPublisher?
    var subscriber : OTSubscriber?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bounds = UIScreen.mainScreen().bounds
        let screenWidth = bounds.size.width
        let screenHeight = bounds.size.height
        
        self.scrollView.contentSize = CGSize(width: screenWidth, height: screenHeight)
        
        // 2016-06-19 : As the view is loaded initialize a new instance of OTSession
        session = OTSession(apiKey: ApiKey, sessionId: SessionID, delegate: self)
        
        // 2016-06-19 : connect to the Server provided session details.
        doConnect()
    }
    
    override func viewWillAppear(animated: Bool) {
        // 2016-06-19 : As the view comes into the foreground, begin the connection process.
        
        // doConnect()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // 2016-06-19 : OpenTok Methods
    
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
    
    /**
     * Sets up an instance of OTPublisher to use with this session. OTPubilsher
     * binds to the device camera and microphone, and will provide A/V streams
     * to the OpenTok session.
     */
    func doPublish() {
        publisher = OTPublisher(delegate: self)
        
        var maybeError : OTError?
        session?.publish(publisher, error: &maybeError)
        
        if let error = maybeError {
            showAlert(error.localizedDescription)
        }
        
        scrollView.addSubview(publisher!.view)
        
        publisher!.view.frame = CGRect(x: 0.0, y: 0.0, width: videoWidth, height: videoHeight)
        
    }
    
    /**
     * Instantiates a subscriber for the given stream and asynchronously begins the
     * process to begin receiving A/V content for this stream. Unlike doPublish,
     * this method does not add the subscriber to the view hierarchy. Instead, we
     * add the subscriber only after it has connected and begins receiving data.
     */
    func doSubscribe(stream : OTStream) {
        if let session = self.session {
            subscriber = OTSubscriber(stream: stream, delegate: self)
            
            var maybeError : OTError?
            session.subscribe(subscriber, error: &maybeError)
            if let error = maybeError {
                showAlert(error.localizedDescription)
            }
        }
    }
    
    /**
     * 2016-06-19 : Cleans the subscriber from the view hierarchy, if any.
     */
    func doUnsubscribe() {
        if let subscriber = self.subscriber {
            var maybeError : OTError?
            session?.unsubscribe(subscriber, error: &maybeError)
            if let error = maybeError {
                showAlert(error.localizedDescription)
            }
            
            subscriber.view.removeFromSuperview()
            self.subscriber = nil
        }
    }
    
    // 2016-06-19 : OTSession delegate callbacks
    
    func sessionDidConnect(session: OTSession) {
        NSLog("sessionDidConnect (\(session.sessionId))")
        
        // We have successfully connected, now instantiate a publisher and
        // begin pushing A/V streams into OpenTok.
        doPublish()
    }
    
    // 2016-06-19 : OTSession sessionDidDisconnect
    func sessionDidDisconnect(session : OTSession) {
        NSLog("Session disconnected (\( session.sessionId))")
    }
    
    // 2016-06-19 : OTSession streamCreated
    func session(session: OTSession, streamCreated stream: OTStream) {
        NSLog("session streamCreated (\(stream.streamId))")
        
        // (if NO == subscribeToSelf): Begin subscribing to a stream we
        // have seen on the OpenTok session.
        if subscriber == nil && !SubscribeToSelf {
            doSubscribe(stream)
        }
    }
    
    // 2016-06-19 : OTSession streamDestroyed
    func session(session: OTSession, streamDestroyed stream: OTStream) {
        NSLog("session streamCreated (\(stream.streamId))")
        
        if subscriber?.stream.streamId == stream.streamId {
            doUnsubscribe()
        }
    }
    
    // 2016-06-19 : OTSession connectionCreated
    func session(session: OTSession, connectionCreated connection : OTConnection) {
        NSLog("session connectionCreated (\(connection.connectionId))")
    }
    
    // 2016-06-19 : OTSession connectionDestroyed
    func session(session: OTSession, connectionDestroyed connection : OTConnection) {
        NSLog("session connectionDestroyed (\(connection.connectionId))")
    }
    
    // 2016-06-19 : OTSession didFailWithError
    func session(session: OTSession, didFailWithError error: OTError) {
        NSLog("session didFailWithError (%@)", error)
    }
    
    // 2016-06-19 : OTSubscriber delegate callbacks
    func subscriberDidConnectToStream(subscriberKit: OTSubscriberKit) {
        NSLog("subscriberDidConnectToStream (\(subscriberKit))")
        if let view = subscriber?.view {
            view.frame =  CGRect(x: 0.0, y: videoHeight, width: videoWidth, height: videoHeight)
            self.scrollView.addSubview(view)
        }
    }
    
    // 2016-06-19 : OTSubscriber didFailWithError
    func subscriber(subscriber: OTSubscriberKit, didFailWithError error : OTError) {
        NSLog("subscriber %@ didFailWithError %@", subscriber.stream.streamId, error)
    }
    
    // 2016-06-19 : OTPublisher delegate callbacks
    func publisher(publisher: OTPublisherKit, streamCreated stream: OTStream) {
        NSLog("publisher streamCreated %@", stream)
        
        // (if YES == subscribeToSelf): Our own publisher is now visible to
        // all participants in the OpenTok session. We will attempt to subscribe to
        // our own stream. Expect to see a slight delay in the subscriber video and
        // an echo of the audio coming from the device microphone.
        if subscriber == nil && SubscribeToSelf {
            doSubscribe(stream)
        }
    }
    
    // 2016-06-19 : OTPublisher streamDestroyed
    func publisher(publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        NSLog("publisher streamDestroyed %@", stream)
        
        if subscriber?.stream.streamId == stream.streamId {
            doUnsubscribe()
        }
    }
    
    // 2016-06-19 : OTPublisher didFailWithError
    func publisher(publisher: OTPublisherKit, didFailWithError error: OTError) {
        NSLog("publisher didFailWithError %@", error)
    }
    
    // 2016-06-19 : Alert
    func showAlert(message: String) {
        // show alertview on main UI
        dispatch_async(dispatch_get_main_queue()) {
            // create the alert
            let alert = UIAlertController(title: "OTError", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            
            // add the actions (button)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
            
            // show the alert
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
}


