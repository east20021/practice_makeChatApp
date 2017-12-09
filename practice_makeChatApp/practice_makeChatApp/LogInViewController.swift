//
//  LogInViewController.swift
//  practice_makeChatApp
//
//  Created by lee on 2017. 12. 5..
//  Copyright © 2017년 smith. All rights reserved.
//

import UIKit
import GoogleSignIn

class LogInViewController: UIViewController , GIDSignInUIDelegate, GIDSignInDelegate {

    @IBOutlet weak var anonymousButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        anonymousButton.layer.borderWidth = 2.0
        anonymousButton.layer.borderColor = UIColor.white.cgColor
        
        GIDSignIn.sharedInstance().clientID = "222404520984-2i76eie76ocjrpvre5f4jj41s84ntmuj.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func loginAnonymouslyDidTapped(_ sender: Any) {
        print("login anonymously did tapped")
        //anonymously log users in
        //switch view by setting navigation controller as root view controller
        Helper.helper.loginAnonymously()
    }
    
    @IBAction func googleLoginDidTapped(_ sender: Any) {
        print("google login did tapped")
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if error != nil {
            print(error.localizedDescription)
            return
        }
        print(user.authentication)
        Helper.helper.logInWithGoogle(authentication: user.authentication)
    }

}
