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
        tblProfile.tableHeaderView = createTableHeaderView()
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
                    UserDefaults.standard.setValue(nil, forKey: "email")
                    UserDefaults.standard.setValue(nil, forKey: "name")
                    self?.showLoginScreen()
                }
            }

        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet, animated: true)
    }
    
    func createTableHeaderView()->UIView?{
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return nil
        }
        let safeEmail = DatabaseManager.shared.getSafeEmail(mail: email)
        let fileName = safeEmail+"-profile-picture.png"
        let path = "images/"+fileName
        
        let headerView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: view.frame.size.width,
                                              height: 300))
        headerView.backgroundColor = .link
        
        let imageView = UIImageView(frame: CGRect(x: (headerView.frame.size.width-150)/2,
                                                  y: 75,
                                                  width: 150,
                                                  height: 150))
        
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.size.width/2
        headerView.addSubview(imageView)
        
        StorageManager.shared.downloadURL(for: path) { [weak self] result in
            switch result{
            case .success(let url):
                self?.downloadImage(imageView: imageView, url: url)
                
            case .failure(let error):
                print("Failed to get download url: \(error)")
                
            }
        }
        
        return headerView
    }
    
    func downloadImage(imageView: UIImageView,url: URL){
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else{
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
        }.resume()
    }
}
