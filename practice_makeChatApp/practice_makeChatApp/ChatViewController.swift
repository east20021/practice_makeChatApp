//
//  ChatViewController.swift
//  practice_makeChatApp
//
//  Created by lee on 2017. 12. 5..
//  Copyright © 2017년 smith. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    var message = [JSQMessage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderId = "1"
        self.senderDisplayName = "smith"

        // Do any additional setup after loading the view.
    }
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        print("didPressSendButton")
        print("\(text)")
        print(senderId)
        print(senderDisplayName)
        message.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
        print(message)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        print("didPressAccessoryButton")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func logoutDidTapped(_ sender: Any) {
        
        //Create a main storyboard instance
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        //From main storyboard instantiate a navigation controller
        let LogInVC = storyboard.instantiateViewController(withIdentifier: "LogInVC") as! LogInViewController
        
        //Get the app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        
        //Set Navigation Controller as root view controller
        appDelegate.window?.rootViewController = LogInVC
    }
    
}
