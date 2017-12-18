//
//  Helper.swift
//  practice_makeChatApp
//
//  Created by lee on 2017. 12. 6..
//  Copyright © 2017년 smith. All rights reserved.
//

import Foundation
import FirebaseAuth
import UIKit
import GoogleSignIn
import FirebaseDatabase

class Helper {
    static let helper = Helper()
    
    func loginAnonymously() {
        print("login anonymously did tapped")
        //anonymously log users in
        //switch view by setting navigation controller as root view controller
        
        Auth.auth().signInAnonymously {(anonymousUser, error) in
            if error == nil {
                print("UserID: \(anonymousUser!.uid)")
                
                let newUser = Database.database().reference().child("users").child((anonymousUser?.uid)!)
                newUser.setValue(["displayname" : "anonymous", "id" : "\(anonymousUser!.uid)", "profileUrl" : ""])
                self.switchToNavigationViewController()
                
            } else {
                print(error!.localizedDescription)
                return
            }
        }
    }
    
    func logInWithGoogle(authentication: GIDAuthentication) {
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) {(user, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            } else {
                print(user?.email as Any)
                print(user?.displayName as Any)
                print(user?.photoURL as Any)
                
                let newUser = Database.database().reference().child("users").child(user!.uid)
                newUser.setValue(["displayname" : "\(user!.displayName!)", "id" : "\(user!.uid)", "profileUrl" : "\(user!.photoURL!)"])
                
                self.switchToNavigationViewController()
            }
        }
    }
    
    func switchToNavigationViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let naviVC = storyboard.instantiateViewController(withIdentifier: "NavigationVC") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = naviVC
    }
    
    
}
