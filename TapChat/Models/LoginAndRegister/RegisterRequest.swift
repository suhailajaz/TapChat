//
//  RegisterRequest.swift
//  TapChat
//
//  Created by suhail on 25/10/23.
//

import Foundation

struct RegisterRequest : Encodable{
    let userEmail,userPassWord,fName,lName: String
    
    var profilePictureFileName: String{
        let safeEmail = DatabaseManager.shared.getSafeEmail(mail: userEmail)
        return "\(safeEmail)-profile-picture.png"
    }
}
