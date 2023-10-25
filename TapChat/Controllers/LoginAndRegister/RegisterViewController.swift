//
//  RegisterViewController.swift
//  TapChat
//
//  Created by suhail on 24/10/23.
//

import UIKit

class RegisterViewController: UIViewController {
    
    
    @IBOutlet var txtFirstName: UITextField!
    @IBOutlet var txtLastName: UITextField!
    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtPassword: UITextField!
    @IBOutlet var imgProfile: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtEmail.delegate = self
        txtPassword.delegate = self
        txtFirstName.delegate = self
        txtLastName.delegate = self
        
        title = "Register"
        imgProfile.layer.masksToBounds = true
        imgProfile.layer.cornerRadius = imgProfile.frame.size.width/2.0
        
        
        addTapGestureToProfileImage()

    }
    
}

// MARK: - IBACTIONS
extension RegisterViewController{
 
    @IBAction func registerTapped(_ sender: Any) {
        
        txtFirstName.resignFirstResponder()
        txtLastName.resignFirstResponder()
        txtEmail.resignFirstResponder()
        txtPassword.resignFirstResponder()
        
        let request = RegisterRequest(userEmail: txtEmail.text!, userPassWord: txtPassword.text!, fName: txtFirstName.text!, lName: txtLastName.text!)
        let validation = RegisterValidation()
        let validationResult = validation.validate(request: request)
        
        if(validationResult.success){
            //login validation is successful
            //firebase login
            
        }else{
            self.displayAlert(alertMessage: validationResult.errorMessage!)
        }
        
    }
    
  
}
// MARK: - User Defined Methods
extension RegisterViewController{
    func addTapGestureToProfileImage(){
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePicture))
        imgProfile.addGestureRecognizer(gesture)
        
    }
    @objc func didTapChangeProfilePicture(){
        self.presentPictureSelectActionSheet()
    }
}

// MARK: - TextField Delegate
extension RegisterViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtFirstName{
            txtLastName.becomeFirstResponder()
        }else if textField == txtLastName{
            txtEmail.becomeFirstResponder()
        }else if textField == txtEmail{
            txtPassword.becomeFirstResponder()
        }else if textField == txtPassword{
            registerTapped(textField)
        }
        return true
    }
}

