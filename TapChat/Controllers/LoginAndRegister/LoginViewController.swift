//
//  LoginViewController.swift
//  TapChat
//
//  Created by suhail on 24/10/23.
//

import UIKit
import JGProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtPassword: UITextField!
    @IBOutlet var btnLogin: UIButton!
  
    let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtEmail.delegate = self
        txtPassword.delegate = self
        title = "Log In"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
    }
}

// MARK: - IBACTIONS
extension LoginViewController{
    
    @IBAction func loginTapped(_ sender: Any) {
     
        txtEmail.resignFirstResponder()
        txtPassword.resignFirstResponder()
        
        let request = LoginRequest(userEmail: txtEmail.text!, userPassWord: txtPassword.text!)
        let validation = LoginValidation()
        let validationResult = validation.validate(request: request)
        
        spinner.show(in: view)
        
        if(validationResult.success){
            //login validation is successful
            //firebase login
            AuthManager.shared.loginUser(request) { success in
                self.spinner.dismiss()
                if success{
                    NotificationCenter.default.post(name: .didLoginNotification, object: nil)
                    self.navigationController?.dismiss(animated: true)
                }
            }
            
        }else{
            self.spinner.dismiss()
            self.displayAlert(alertMessage: validationResult.errorMessage!)
        }

    }
    
    @objc func didTapRegister(){
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterViewController
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - TextField Delegate
extension LoginViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if textField == txtEmail{
            txtPassword.becomeFirstResponder()
        }else if textField == txtPassword{
            loginTapped(textField)
        }
        return true
    }
    
}
