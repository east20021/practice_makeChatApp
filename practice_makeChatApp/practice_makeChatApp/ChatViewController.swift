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
import SDWebImage

class ChatViewController: JSQMessagesViewController {
    var messages = [JSQMessage]()
    var avatarDict = [String: JSQMessagesAvatarImage]()
    var messageRef = Database.database().reference().child("message")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUser = Auth.auth().currentUser {
            self.senderId = currentUser.uid
            
            if currentUser.isAnonymous == true {
                self.senderDisplayName = "anonymous"
            } else {
                self.senderDisplayName = "\(currentUser.displayName)"
            }
        }
        observeMessage()
    }
    
    func observeUser(_ id: String) {
        Database.database().reference().child("users").child(id).observe(.value, with: { snapshot in
            if let dict = snapshot.value as? [String: AnyObject] {
                let avatarUrl = dict["profileUrl"] as! String
                self.setupAvatar(url: avatarUrl, messageId: id)
            }
        })
    }
    
    func setupAvatar(url: String, messageId: String) {
//        if url != "" {
//            let fileUrl = URL(string: url)
        
//            let data = NSData(contentsOf: fileUrl! as! URL)
//            let image = UIImage(data: data! as Data)
//            let userImg = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 30)
//            self.avatarDict[messageId] = userImg
//        } else {
//            avatarDict[messageId] = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "profileImage"), diameter: 30)
//        }
        avatarDict[messageId] = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "profileImage"), diameter: 30)
        collectionView.reloadData()
    }
    
    func observeMessage() {
        messageRef.observe(.childAdded, with: { snapshot in
            if let dict = snapshot.value as? [String: AnyObject] {
                let mediaType = dict["MediaType"] as! String
                let senderId = dict["senderId"] as! String
                let senderName = dict["senderName"] as! String
                
                self.observeUser(senderId)
                
                
                switch mediaType {
                    case "TEXT":
                        let text = dict["text"] as! String
                        self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
                    
                    
                    case "PHOTO":
//                        var photo = JSQPhotoMediaItem(image: nil)
//                        let fileUrl = dict["fileUrl"] as! String
//                        let url = URL(string: fileUrl)
//
//                        if let cachePhoto = (self.photoCache.object(forKey: fileUrl as AnyObject) as? JSQPhotoMediaItem) {
//                            photo = cachePhoto
//                            self.collectionView.reloadData()
//                        } else {
//                            DispatchQueue.global(qos: .userInteractive).async {
//                                let data = NSData(contentsOf: url!)
//                                DispatchQueue.main.async {
//                                    let picture = UIImage(data: data! as Data)
//                                    photo?.image = picture
//                                    self.collectionView.reloadData()
//                                    self.photoCache.setObject(photo!, forKey: fileUrl as AnyObject)
//                                    print("1")
//                                }
//                            }
//                        }
                        let photo = JSQPhotoMediaItem(image: nil)
                        let fileUrl = dict["fileUrl"] as! String
                        let downloader = SDWebImageDownloader.shared()
                        downloader.downloadImage(with: URL(string: fileUrl), options: [], progress: nil, completed: { ( image, data, error, finished) in
                            DispatchQueue.main.async {
                                photo?.image = image
                                self.collectionView.reloadData()
                            }

                        })
                        self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: photo))
                       
                    
                        if self.senderId == senderId {
                            photo?.appliesMediaViewMaskAsOutgoing = true
                        } else {
                            photo?.appliesMediaViewMaskAsOutgoing = false
                        }
                    
                    case "VIDEO":
                        let fileUrl = dict["fileUrl"] as! String
                        let video = URL(string: fileUrl)
                        let videoItem = JSQVideoMediaItem(fileURL: video, isReadyToPlay: true)
                        self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: videoItem))
                        
                    
                        if self.senderId == senderId {
                            videoItem?.appliesMediaViewMaskAsOutgoing = true
                        } else {
                            videoItem?.appliesMediaViewMaskAsOutgoing = false
                    }
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
        self.finishSendingMessage()
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
        let message = messages[indexPath.item]
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        if message.senderId == self.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.black)
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.blue)
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
        
        return avatarDict[message.senderId]
        //return JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "profileImage"), diameter: 30)
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
            sendMedia(picture: picture, video: nil)
        }
        else if let video = info[UIImagePickerControllerMediaURL] as? NSURL {
            sendMedia(picture: nil, video: video)
        }
        
        self.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
        
    }
}
