//
//  LoginValidation.swift
//  TapChat
//
//  Created by suhail on 25/10/23.
//

import Foundation

struct LoginValidation{
    
    func validate(request: LoginRequest)->ValidationResult{
        if(request.userEmail.count>0 && request.userPassWord.count>0){
            if(request.userEmail.validateEmail()){
                return ValidationResult(success: true, errorMessage: nil)
            }else{
                return ValidationResult(success: false, errorMessage: "Please enter a valid email to login")
            }
        }
        return ValidationResult(success: false, errorMessage: "Please enter valid credentails to login")
    }
    
    
}
