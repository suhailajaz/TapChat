//
//  ProfileViewController.swift
//  TapChat
//
//  Created by suhail on 24/10/23.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet var tblProfile: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblProfile.delegate = self
        tblProfile.dataSource = self
    }
    
}

extension ProfileViewController:UITableViewDelegate,UITableViewDataSource{
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Log Out"
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tblProfile.deselectRow(at: indexPath, animated: true)
        showLogoutActionSheet()
    }
}

//user defined methods
extension ProfileViewController{
    func showLogoutActionSheet(){
        
        let actionSheet = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            
            AuthManager.shared.logoutUser { success in
                if success{
                    self?.showLoginScreen()
                }
            }

        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet, animated: true)
    }
}
