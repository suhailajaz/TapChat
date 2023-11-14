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
    
    @IBOutlet var lblNoConversations: UILabel!
    let spinner = JGProgressHUD(style: .dark)
    private var conversations = [Conversation]()
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapCompose))
        
        tblConversations.dataSource = self
        tblConversations.delegate = self
        tblConversations.register(ConversationTableViewCell.nib, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        
        fetchConversations()
        startListeningForConversations()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLoginNotification, object: nil, queue: .main, using: { [weak self] _ in
            self?.startListeningForConversations()
        })
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
        let model = conversations[indexPath.row]
        openConversation(model)
    }
    
    func openConversation(_ model:Conversation){
        let vc = storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatViewController
        vc.otherUserEmail = model.otherUserEmail
        vc.title = model.name
        vc.conversationId = model.id
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .delete
//    }
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete{
//            
//            let conversationID = conversations[indexPath.row].id
//            tableView.beginUpdates()
//            DatabaseManager.shared.deleteConversation(conversationId: conversationID) { [weak self] success in
//                self?.conversations.remove(at: indexPath.row)
//                tableView.deleteRows(at: [indexPath], with: .left)
//            }
//            tableView.endUpdates()
//        }
//    }
}

//userdefined methods
extension ConversationsViewController{
    
    func fetchConversations(){
        
    }
    
    @objc func didTapCompose(){
        let vc = StoryBoards.newConversations.instantiateViewController(withIdentifier: "NewConvos") as! NewConversationsViewController
        vc.completion = { [weak self] result in
            print("\(result)")
            let currentConversation = self?.conversations
            if let targetConversation = currentConversation?.first(where: {
                $0.otherUserEmail == DatabaseManager.shared.getSafeEmail(mail: result.email)
            }){
                let vc = self?.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatViewController
                vc.otherUserEmail = targetConversation.otherUserEmail
                vc.isNewConversation = false
                vc.title = targetConversation.name
                vc.conversationId = targetConversation.id
                vc.navigationItem.largeTitleDisplayMode = .never
                self?.navigationController?.pushViewController(vc, animated: true)
            }else{
                self?.createNewConversation(result: result)
            }
                
                
                
          
            
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
        if let observer = loginObserver{
            NotificationCenter.default.removeObserver(observer)
        }
        let safeCurrentUserEmail = DatabaseManager.shared.getSafeEmail(mail: currentUserEmail)
        DatabaseManager.shared.getAllConversations(for: safeCurrentUserEmail) { [weak self] result in
            switch result{
            case .success(let conversations):
                guard !conversations.isEmpty else{
                    DispatchQueue.main.async{
                        self?.tblConversations.isHidden = true
                        self?.lblNoConversations.isHidden = false
                    }
                 
                    print("Conversation are empty")
                    return
                }
                
             
                self?.conversations = conversations
                DispatchQueue.main.async{
                    self?.tblConversations.isHidden = false
                    self?.lblNoConversations.isHidden = true
                    self?.tblConversations.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async{
                    self?.tblConversations.isHidden = true
                    self?.lblNoConversations.isHidden = false
                }
                print("Failed to get conversations: \(error)")
            }
        }
    }
}
