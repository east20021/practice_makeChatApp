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

class Helper {
    static let helper = Helper()
    
    func loginAnonymously() {
        print("login anonymously did tapped")
        //anonymously log users in
        //switch view by setting navigation controller as root view controller
        
        Auth.auth().signInAnonymously{ (user, error) in
            if error == nil {
                print("UserID: \(user!.uid)")
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let naviVC = storyboard.instantiateViewController(withIdentifier: "NavigationVC") as! UINavigationController
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = naviVC
                
            } else {
                print(error!.localizedDescription)
                return
            }
        }
        
    }
    
}
