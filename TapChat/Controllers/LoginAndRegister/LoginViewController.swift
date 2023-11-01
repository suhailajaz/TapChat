//
//  LoginViewController.swift
//  TapChat
//
//  Created by suhail on 24/10/23.
//

import UIKit


class LoginViewController: UIViewController {

    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtPassword: UITextField!
    @IBOutlet var btnLogin: UIButton!
  
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
        
        if(validationResult.success){
            //login validation is successful
            //firebase login
            AuthManager.shared.loginUser(request) { success in
                if success{
                    self.navigationController?.dismiss(animated: true)
                }
            }
            
        }else{
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
