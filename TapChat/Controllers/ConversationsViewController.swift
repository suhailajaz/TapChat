//
//  ViewController.swift
//  TapChat
//
//  Created by suhail on 24/10/23.
//

import UIKit
import JGProgressHUD

class ConversationsViewController: UIViewController {
    
    @IBOutlet var tblConversations: UITableView!
    let spinner = JGProgressHUD(style: .dark)
    private var conversations = [Conversation]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapCompose))
        
        tblConversations.dataSource = self
        tblConversations.delegate = self
        tblConversations.register(ConversationTableViewCell.nib, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        
        fetchConversations()
        startListeningForConversations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !AuthManager.shared.checkLoginState(){
            self.showLoginScreen()
        }
    }
    
}
//tableview methods
extension ConversationsViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        cell.configure(with: conversations[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatViewController
        vc.otherUserEmail = conversations[indexPath.row].otherUserEmail
        vc.title = conversations[indexPath.row].name
        vc.conversationId = conversations[indexPath.row].id
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

//userdefined methods
extension ConversationsViewController{
    
    func fetchConversations(){
        
    }
    
    @objc func didTapCompose(){
        let vc = StoryBoards.newConversations.instantiateViewController(withIdentifier: "NewConvos") as! NewConversationsViewController
        vc.completion = { [weak self] result in
            print("\(result)")
            self?.createNewConversation(result: result)
            
        }
        let navController = UINavigationController(rootViewController: vc)
        present(navController,animated: false)
        
    }
    func createNewConversation(result: SearchResult){
        let name = result.name
        let email = result.email
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatViewController
        vc.title = name
        vc.isNewConversation = true
        vc.otherUserEmail = email
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    func startListeningForConversations(){
        guard let currentUserEmail = getEmail() else{
            return
        }
        let safeCurrentUserEmail = DatabaseManager.shared.getSafeEmail(mail: currentUserEmail)
        DatabaseManager.shared.getAllConversations(for: safeCurrentUserEmail) { [weak self] result in
            switch result{
            case .success(let conversations):
                guard !conversations.isEmpty else{
                    print("Conversation are empty")
                    return
                }
                self?.conversations = conversations
                DispatchQueue.main.async{
                    self?.tblConversations.reloadData()
                }
            case .failure(let error):
                print("Failed to get conversations: \(error)")
            }
        }
    }
}
