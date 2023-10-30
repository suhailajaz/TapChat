//
//  DatabaseManager.swift
//  TapChat
//
//  Created by suhail on 30/10/23.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager{
    
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
    public func test(){
        database.child("aaliya").setValue(["age":11,"address":"model town","single": true])
    }
    
}
// MARK: - Account Management
extension DatabaseManager{
    
    ///checks if a user already exists in the realtime databse
    public func userExists(with email: String,
                           completion: @escaping ((Bool)->Void)){
        
        let safeEmail = getSafeEmail(mail: email)
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            //even if a user already exists, this key returns flase....
            guard  snapshot.value as? String != nil  else{
                completion(false)
                return
            }
            print("User with email already exists!")
            completion(true)
        }
    }
    
    ///Inserts new user to realtime databse
    public func insertUser(user: RegisterRequest){
        
        let safeEmail = getSafeEmail(mail: user.userEmail)
        database.child(safeEmail).setValue([
            "first_name" : user.fName,
            "last_name"  : user.lName
        ])
    }
    
    public func getSafeEmail(mail: String)->String{
        var safeEmail = mail.replacingOccurrences(of: ".", with: "-")
         safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
}
