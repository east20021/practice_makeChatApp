//
//  LogInViewController.swift
//  practice_makeChatApp
//
//  Created by lee on 2017. 12. 5..
//  Copyright © 2017년 smith. All rights reserved.
//

import UIKit
import FirebaseAuth

class LogInViewController: UIViewController {

    @IBOutlet weak var anonymousButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        anonymousButton.layer.borderWidth = 2.0
        anonymousButton.layer.borderColor = UIColor.white.cgColor
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
        
        //Create a main storyboard instance
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        //From main storyboard instantiate a navigation controller
        let naviVC = storyboard.instantiateViewController(withIdentifier: "NavigationVC") as! UINavigationController
        
        //Get the app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        
        //Set Navigation Controller as root view controller
        appDelegate.window?.rootViewController = naviVC
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
