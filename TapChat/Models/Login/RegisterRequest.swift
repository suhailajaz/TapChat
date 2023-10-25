//
//  RegisterRequest.swift
//  TapChat
//
//  Created by suhail on 25/10/23.
//

import Foundation

struct RegisterRequest : Encodable{
    let userEmail,userPassWord,fName,lName: String
}
