//
//  RegisterViewController.swift
//  TapChat
//
//  Created by suhail on 24/10/23.
//

import UIKit
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    
    @IBOutlet var txtFirstName: UITextField!
    @IBOutlet var txtLastName: UITextField!
    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtPassword: UITextField!
    @IBOutlet var imgProfile: UIImageView!
    
    let spinner = JGProgressHUD(style: .dark)
    
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
        let newUserImage = imgProfile.image
        txtFirstName.resignFirstResponder()
        txtLastName.resignFirstResponder()
        txtEmail.resignFirstResponder()
        txtPassword.resignFirstResponder()
        
        let request = RegisterRequest(userEmail: txtEmail.text!, userPassWord: txtPassword.text!, fName: txtFirstName.text!, lName: txtLastName.text!)
        let validation = RegisterValidation()
        let validationResult = validation.validate(request: request)
        spinner.show(in: view)
        if(validationResult.success){
            //register validation is successful on the client side
            
            //checking if the user alread exists in the realtime database
            DatabaseManager.shared.userExists(with: request.userEmail) { exists in
                
                
                guard !exists else {
                    self.spinner.dismiss()
                    //user alreay exists
                    self.displayAlert(alertMessage: "Looks like a user account for this email id already exists!")
                    return
                }
                //aading the user to firebase auth
                AuthManager.shared.registerUser(request) { [weak self] success in
                    self?.spinner.dismiss()
                    if success{
                        //Adding the newly registered user in firebase auth to realtime database
                        DatabaseManager.shared.insertUser(user: request) { success in
                            if success{
                                //upload image
                                guard let image = newUserImage ,let data = image.pngData() else {
                                    print("Failed to fetched image from the image view in register screen")
                                    return
                                }
                                let fileName = request.profilePictureFileName
                                
                                StorageManager.shared.uploadProfilepicture(with: data, fileName: fileName) { result in
                                    switch result{
                                    case .success(let downloadUrl):
                                        UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                        print(downloadUrl)
                                    case .failure(let error):
                                        print("Storage manager error: \(error)")
                                    }
                                }
                            }
                        }
                        self?.navigationController?.dismiss(animated: true)
                    }
                }
            }
            
        }else{
            self.spinner.dismiss()
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
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
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

