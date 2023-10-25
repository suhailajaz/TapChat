//
//  RegisterViewControllerExtension.swift
//  TapChat
//
//  Created by suhail on 25/10/23.
//

import Foundation
import UIKit
// MARK: - Handles Image Picking and Setting
extension RegisterViewController{
    
    func presentPictureSelectActionSheet(){
        let alert = UIAlertController(title: "Select Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            //present camera
            self?.selectImageViaCamera()
        }))
        alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            //present photo library
            self?.selectImageViaPhotoLibrary()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert,animated: true)
    }
    
    func selectImageViaCamera(){
        print("Camera Tapped")
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc,animated: true)
        
    }
    
    func selectImageViaPhotoLibrary(){
        print("Photo Library Tapped Tapped")
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc,animated: true)
    }

}

extension RegisterViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else{
            return
        }
        self.imgProfile.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
