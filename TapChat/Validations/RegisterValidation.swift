//
//  RegisterValidation.swift
//  TapChat
//
//  Created by suhail on 25/10/23.
//

import Foundation

struct RegisterValidation{
    
    func validate(request: RegisterRequest)->ValidationResult{
        if(request.userEmail.count>0 && request.userPassWord.count>5 && request.fName.count>0 && request.lName.count>0){
            if(request.userEmail.validateEmail()){
                return ValidationResult(success: true, errorMessage: nil)
            }else{
                return ValidationResult(success: false, errorMessage: "Please enter a valid email to create a new account")
            }
        }
        return ValidationResult(success: false, errorMessage: "Please enter valid credentails to create a new accounr")
    }
    
    
}
