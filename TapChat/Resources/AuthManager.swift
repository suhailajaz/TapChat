//
//  AuthManager.swift
//  TapChat
//
//  Created by suhail on 25/10/23.
//

import Foundation
import FirebaseAuth

struct AuthManager{
    
    static let shared = AuthManager()
    
    func registerUser(_ user: RegisterRequest,completion: @escaping (Bool)->()){
      
        FirebaseAuth.Auth.auth().createUser(withEmail: user.userEmail, password: user.userPassWord) { authResult, error in
            guard let result = authResult, error == nil else{
                print("Error creating user")
                return
            }
        
            print("Created User: \(result.user)")
            completion(true)
            
        }
    }
    
    func loginUser(_ user: LoginRequest,completion: @escaping (Bool)->()){
        
        FirebaseAuth.Auth.auth().signIn(withEmail: user.userEmail, password: user.userPassWord) { authResult, error in
            guard let result = authResult, error == nil else{
                print("Failed to login user with email: \(user.userEmail)")
                return
            }
            print("Logged in User: \(result.user)")
            completion(true)
        }
        
    }
    
    func checkLoginState()->Bool{
        if FirebaseAuth.Auth.auth().currentUser == nil{
            return false
        }else{
            return true
        }
    }
}
