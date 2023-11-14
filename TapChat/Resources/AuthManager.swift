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
                completion(false)
                return
            }
        
            print("Created User: \(result.user)")
            UserDefaults.standard.set(user.userEmail, forKey: "email")
            let safeEmail = DatabaseManager.shared.getSafeEmail(mail: user.userEmail)
            DatabaseManager.shared.getDataFor(path: safeEmail) { result in
                switch result{
                case .success(let data):
                    guard let userData = data as? [String:Any],
                          let firstName = userData["first_name"],
                          let lastName = userData["last_name"] else{
                        return
                    }
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                case .failure(let error):
                    print("Failed to read data for path: \(error)")
                }
            }
            completion(true)
            
        }
    }
    
    func loginUser(_ user: LoginRequest,completion: @escaping (Bool)->()){
        
        FirebaseAuth.Auth.auth().signIn(withEmail: user.userEmail, password: user.userPassWord) { authResult, error in
            guard let result = authResult, error == nil else{
                print("Failed to login user with email: \(user.userEmail)")
                completion(false)
                return
            }
            
            print("Logged in User: \(result.user)")
            
            let safeEmail = DatabaseManager.shared.getSafeEmail(mail: user.userEmail)
            DatabaseManager.shared.getDataFor(path: safeEmail) { result in
                switch result{
                case .success(let data):
                    guard let userData = data as? [String:Any],
                          let firstName = userData["first_name"],
                          let lastName = userData["last_name"] else{
                        return
                    }
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                case .failure(let error):
                    print("Failed to read data for path: \(error)")
                }
            }
            
            UserDefaults.standard.set(user.userEmail, forKey: "email")
            completion(true)
        }
        
    }
    
    func logoutUser(completion: @escaping ((Bool)->Void)){
        do{
            try FirebaseAuth.Auth.auth().signOut()
            completion(true)
        }catch{
            print("Failed to logout user.")
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
