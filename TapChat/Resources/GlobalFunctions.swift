//
//  GlobalFunctions.swift
//  TapChat
//
//  Created by suhail on 08/11/23.
//

import Foundation

///returns the email of the logged in user
public func getEmail()->String?{
    guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
        return nil
    }
    return email
}
///returns the name of the logged in user
public func getName()->String?{
    guard let name = UserDefaults.standard.value(forKey: "name") as? String else{
        return nil
    }
    return name
}
