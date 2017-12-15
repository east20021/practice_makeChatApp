//
//  ChatViewController.swift
//  practice_makeChatApp
//
//  Created by lee on 2017. 12. 5..
//  Copyright © 2017년 smith. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class ChatViewController: JSQMessagesViewController {
    var messages = [JSQMessage]()
    
    var messageRef = Database.database().reference().child("message")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderId = "1"
        self.senderDisplayName = "smith"

        // Do any additional setup after loading the view.
        
       
    
//        messageRef.childByAutoId().setValue("first message")
//        messageRef.childByAutoId().setValue("second message")
//        messageRef.observe(DataEventType.value) { (snapshot: DataSnapshot) in
//            print("test")
//            if let dict = snapshot.value as? NSDictionary {
//                print(dict)
//            }
//        }
        observeMessage()
        
    }
    
    func observeMessage() {
        messageRef.observe(.childAdded, with: { snapshot in
            if let dict = snapshot.value as? [String: AnyObject] {
                let mediaType = dict["MediaType"] as! String
                let senderId = dict["senderId"] as! String
                let senderName = dict["senderName"] as! String
                
                switch mediaType {
                    case "TEXT":
                        let text = dict["text"] as! String
                        self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
                    case "PHOTO":
                        let fileUrl = dict["fileUrl"] as! String
                        let url = URL(string: fileUrl)
                        let data = NSData(contentsOf: url!)
                        let picture = UIImage(data: data! as Data)
                        let photo = JSQPhotoMediaItem(image: picture)
                        self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: photo))
                    case "VIDEO":
                        let fileUrl = dict["fileUrl"] as! String
                        let video = URL(string: fileUrl)
                        let videoItem = JSQVideoMediaItem(fileURL: video, isReadyToPlay: true)
                        self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: videoItem))
                    default:
                        print("unknown data type")
                    
                    }
                
                self.collectionView.reloadData()
            }
        })
    }
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
//        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
//        collectionView.reloadData()
//        print(messages)
        
        let newMessage = messageRef.childByAutoId()
        let messageData = ["text": text, "senderId": senderId, "senderName": senderDisplayName, "MediaType": "TEXT"]
        newMessage.setValue(messageData)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        print("didPressAccessoryButton")
        
        let sheet = UIAlertController(title: "Media Message", message: "please select a media", preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (alert: UIAlertAction) in
            
        }
        
        let photoLibrary = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.default) {(alert: UIAlertAction) in
            self.getMediaForm(kUTTypeImage)
        }
        
        let videoLibrary = UIAlertAction(title: "Video Library", style: UIAlertActionStyle.default) {(alert: UIAlertAction) in
            self.getMediaForm(kUTTypeMovie)
        }
        
        sheet.addAction(photoLibrary)
        sheet.addAction(videoLibrary)
        sheet.addAction(cancel)
        self.present(sheet, animated: true, completion: nil)
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func getMediaForm(_ type: CFString) {
        print(type)
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.mediaTypes = [type as String]
        self.present(mediaPicker, animated: true, completion: nil)
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.black)
    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("number of message : \(messages.count)")
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        print("didtapMessageBubbleAtIndexPath: \(indexPath.item)")
        let message = messages[indexPath.item]
        if message.isMediaMessage {
            if let mediaItem = message.media as? JSQVideoMediaItem {
                let player = AVPlayer(url: mediaItem.fileURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true, completion: nil)
            }
        }
    }


    @IBAction func logoutDidTapped(_ sender: Any) {
        
        do {
           try Auth.auth().signOut()
        } catch let error {
            print(error)
        }
        
        print(Auth.auth().currentUser)
        
        //Create a main storyboard instance
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        //From main storyboard instantiate a navigation controller
        let LogInVC = storyboard.instantiateViewController(withIdentifier: "LogInVC") as! LogInViewController
        
        //Get the app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        
        //Set Navigation Controller as root view controller
        appDelegate.window?.rootViewController = LogInVC
    }
    
    func sendMedia(picture: UIImage?, video: NSURL?) {
        print(picture)
        print(Storage.storage().reference())
        if let picture = picture {
            let filePath = "\(Auth.auth().currentUser!)/\(NSDate.timeIntervalSinceReferenceDate)"
            print(filePath)
            let data = UIImageJPEGRepresentation(picture, 0.1)
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            Storage.storage().reference().child(filePath).putData(data!, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print(error?.localizedDescription)
                    return
                }
                let fileUrl = metadata!.downloadURLs![0].absoluteString
                
                let newMessage = self.messageRef.childByAutoId()
                let messageData = ["fileUrl": fileUrl, "senderId": self.senderId, "senderName": self.senderDisplayName, "MediaType": "PHOTO"]
                newMessage.setValue(messageData)
            }
        } else if let video = video {
            let filePath = "\(Auth.auth().currentUser!)/\(Date.timeIntervalSinceReferenceDate)"
            print(filePath)
            let data = NSData(contentsOf: video as URL!)
            let metadata = StorageMetadata()
            metadata.contentType = "video/mp4"
            Storage.storage().reference().child(filePath).putData(data! as Data, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print(error?.localizedDescription)
                    return
                }
                let fileUrl = metadata!.downloadURLs![0].absoluteString

                let newMessage = self.messageRef.childByAutoId()
                let messageData = ["fileUrl": fileUrl, "senderId": self.senderId, "senderName": self.senderDisplayName, "MediaType": "VIDEO"]
                newMessage.setValue(messageData)
            }
        }
    }
    
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did finish picking")
        //get the image
        print(info)
        
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let photo = JSQPhotoMediaItem(image: picture)
            messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: photo))
            sendMedia(picture: picture, video: nil)
        }
        else if let video = info[UIImagePickerControllerMediaURL] as? NSURL {
            let videoItem = JSQVideoMediaItem(fileURL: video as URL!, isReadyToPlay: true)
            messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: videoItem))
            sendMedia(picture: nil, video: video)
        }
        
        self.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
        
    }
}
