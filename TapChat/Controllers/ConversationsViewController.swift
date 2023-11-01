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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        

        if !AuthManager.shared.checkLoginState(){
            
            self.showLoginScreen()
            
        }
    }
    
}

