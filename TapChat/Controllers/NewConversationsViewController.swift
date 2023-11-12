//
//  NewConversationsViewController.swift
//  TapChat
//
//  Created by suhail on 24/10/23.
//

import UIKit
import JGProgressHUD

class NewConversationsViewController: UIViewController {
  
    @IBOutlet var tblAllUsers: UITableView!
    @IBOutlet var lblNoResults: UILabel!
    
    let spinner = JGProgressHUD(style: .dark)
    var users = [[String:String]]()
    var results = [SearchResult]()
    var hasFetched = false
    var completion : ((SearchResult)->Void)?
    
    let searchBar: UISearchBar = {
       let searchBar = UISearchBar()
       searchBar.placeholder = "Search for users..."
       return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
        
        tblAllUsers.register(NewConversationTableViewCell.nib, forCellReuseIdentifier: NewConversationTableViewCell.identifier)
        tblAllUsers.delegate = self
        tblAllUsers.dataSource = self
        
    }
    
}

extension NewConversationsViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else{
            return
        }
        searchBar.resignFirstResponder()
        
        results.removeAll()
        spinner.show(in: view)
        self.searchUsers(query: text)
    }
}

//user defined functions
extension NewConversationsViewController{
    
    @objc func dismissSelf(){
        dismiss(animated: true)
    }
    
    func searchUsers(query: String){
        //check if the users have been fetched to local
        if hasFetched{
            //filter users
            filterUsers(with: query)
        }else{
            //fetch then filter
            DatabaseManager.shared.getAllUsers { [weak self] result in
                switch result{
                case .success(let fetchedUsers):
                    self?.hasFetched = true
                    self?.users = fetchedUsers
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to fetch users: \(error)")
                }
            }
        }

    }
    
    func filterUsers(with term: String){
        guard let currentUserEmail = getEmail() else{
            return
        }
        let safeEmail = DatabaseManager.shared.getSafeEmail(mail: currentUserEmail)
        self.spinner.dismiss()
        
        let filteredResults : [SearchResult] = self.users.filter{
            guard let email = $0["email"], email != safeEmail else{
                return false
            }
            guard let name = $0["name"]?.lowercased() else{
                return false
            }
            return name.hasPrefix(term.lowercased())
        }.compactMap {
            guard let email = $0["email"], let name = $0["name"] else{
            return nil
        }
            return SearchResult(name: name, email: email)
        }
        self.results = filteredResults
        updateUI()
    }
    
    func updateUI(){
        if results.isEmpty{
            self.lblNoResults.isHidden = false
            self.tblAllUsers.isHidden = true
        }else{
            self.lblNoResults.isHidden = true
            self.tblAllUsers.isHidden = false
            self.tblAllUsers.reloadData()
        }
    }
}

extension NewConversationsViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewConversationTableViewCell.identifier, for: indexPath) as! NewConversationTableViewCell
        cell.configure(with: results[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //start conversation
        let targetUserData = results[indexPath.row]
        dismiss(animated: true) { [weak self] in
            self?.completion?(targetUserData)
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
