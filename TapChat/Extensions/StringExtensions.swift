//
//  StringExtensions.swift
//  TapChat
//
//  Create/Users/suhail/Desktop/TapChat/TapChat.xcodeprojd by suhail on 25/10/23.
//

import Foundation

extension String{
    
    func validateEmail()->Bool{
        
        let regex = try! NSRegularExpression(pattern: "(^[0-9a-zA-Z]([-\\.\\w]*[0-9a-zA-Z])*@([0-9a-zA-Z][-\\w]*[0-9a-zA-Z]\\.)+[a-zA-Z]{2,64}$)", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count)) != nil
    }
    
}
