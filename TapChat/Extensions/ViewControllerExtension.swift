//
//  ViewControllerExtension.swift
//  TapChat
//
//  Created by suhail on 25/10/23.
//

import UIKit

extension UIViewController{
    
    func displayAlert(alertMessage: String){
        let alert = UIAlertController(title: "Alert", message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    
}
