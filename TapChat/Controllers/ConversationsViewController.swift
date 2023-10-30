//
//  ViewController.swift
//  TapChat
//
//  Created by suhail on 24/10/23.
//

import UIKit

class ConversationsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        DatabaseManager.shared.test()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        

        if !AuthManager.shared.checkLoginState(){
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen
            present(navController,animated: false)
            
        }
    }
    
}

