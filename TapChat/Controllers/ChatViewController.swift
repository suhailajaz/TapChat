//
//  ChatViewController.swift
//  TapChat
//
//  Created by suhail on 01/11/23.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import AVKit

class ChatViewController: MessagesViewController {
    
    private var senderPhotoURL: URL?
    private var otherUserURL: URL?
    var otherUserEmail = ""
    var isNewConversation = false
    var conversationId: String?
    var messages = [Message]()
    
    private var selfSender: Sender? {
        guard let email = getEmail() else{
            return nil
        }
         let safeEmail = DatabaseManager.shared.getSafeEmail(mail: email)
        return Sender(photoURL: "",
                      senderId: safeEmail,
                      displayName: "Me")
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
    
        setupAttachemntButton()
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationId = conversationId{
            listenForMessages(id: conversationId,shouldScrollToBottom: true)
        }
    }
}
extension ChatViewController: InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let selfSender = self.selfSender, let messageId = ChatResource.shared.createMessageId(otherUserEmail: otherUserEmail) else{
            return
        }
        print("Sending: \(text)")
        //send  message 
        let message = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        if isNewConversation{
            //create a conversation in database
          
            
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: message) { [weak self] success in
                if success{
                    print("Message sent")
                    self?.isNewConversation = false
                    let newConversationID = "conversations_\(message.messageId)"
                    self?.conversationId = newConversationID
                    self?.listenForMessages(id: newConversationID, shouldScrollToBottom: true)
                    self?.messageInputBar.inputTextView.text = nil
                }else{
                    print("Failed to send message")
                }
            }
            
        }else{
            //append to existing conversation in database
            guard let conversationID = conversationId, let name = self.title else{
                return
            }
            DatabaseManager.shared.sendMessage(to: conversationID,otherUserEmail: otherUserEmail,name: name, newMessage: message) { [weak self] success in
                if success{
                    self?.messageInputBar.inputTextView.text = nil
                    print("Sent a new message to an existing conversation.")
                }else{
                    print("Failed to send a n ew message to an existing conversation.")
                }
            }
        }
    }
    
}


extension ChatViewController: MessagesDataSource,MessagesLayoutDelegate,MessagesDisplayDelegate{
    func currentSender() -> MessageKit.SenderType {
        if let sender = selfSender{
            return sender
        }
        fatalError("Self Sender is nil, email should be cached")
       // return Sender(photoURL: "", senderId: "12", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        messages.count
    }
    
}

// MARK: - User Defined Methods
extension ChatViewController{
    
    private func listenForMessages(id: String, shouldScrollToBottom: Bool){
        DatabaseManager.shared.getAllMessagesForConversation(with: id) { [weak self] result in
            switch result{
                
            case .success(let messages):
                guard !messages.isEmpty else{
                    return
                }
                self?.messages = messages
                DispatchQueue.main.async{ [weak self] in
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom{
                        self?.messagesCollectionView.scrollToLastItem()
                    }
                   
                }
            case .failure(let error):
                print("Failed to get messages: \(error)")
            }
        }
    }
    
    func setupAttachemntButton(){
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"),for: .normal)
        button.onTouchUpInside { [weak self] _ in
            //present action sheet
            self?.presentAttachmentActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: true)
    }
    private func presentAttachmentActionSheet(){
        let actionSheet = UIAlertController(title: "Attach Media", message: "What would you like to attach?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: {  [weak self] _ in
            //present photo action sheet
            self?.presentPhotoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] _ in
            self?.presentVideoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default, handler: { _ in
           
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel,handler: nil))
        present(actionSheet,animated: true)
    }
    
    private func presentPhotoInputActionSheet(){
        let actionSheet = UIAlertController(title: "Attach Photo", message: "Where would you like to attach a photo from?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {  [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker,animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {[weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker,animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel,handler: nil))
        present(actionSheet,animated: true)
    }
    
    private func presentVideoInputActionSheet(){
        let actionSheet = UIAlertController(title: "Attach Video", message: "Where would you like to attach a video from?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {  [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker,animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Library", style: .default, handler: {[weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker,animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel,handler: nil))
        present(actionSheet,animated: true)
    }
}
// MARK: - UIImagePickerController delegate methods
extension ChatViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard  let messageId = ChatResource.shared.createMessageId(otherUserEmail: otherUserEmail),let conversationId = conversationId, let name = self.title,let selfSender = self.selfSender else{
            return
        }
        if let  pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage, let pickedImageData = pickedImage.pngData(){
            //photo
            //upload Image
            let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".png"
            StorageManager.shared.uploadMessagePhoto(with: pickedImageData, fileName: fileName) { [weak self] result in
                switch result{
                case .success(let urlString):
                    print("Uploaded message photo: \(urlString)")
                    guard let url = URL(string: urlString), let placeholder = UIImage(systemName: "plus"),let otherUserEmail = self?.otherUserEmail else{
                        return
                    }
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)
                    let message = Message(sender: selfSender,
                                          messageId: messageId,
                                          sentDate: Date(),
                                          kind: .photo(media))
                    DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: name, newMessage: message) { success in
                        if success{
                            print("sent photo message")
                        }else{
                            print("failed to send photo message")
                        }
                    }
                case .failure(let error):
                    print("Message photo upload error/Error in fetching download url for uploaded photo: \(error)")
                }
            }
        }else if let videoUrl = info[.mediaURL] as? URL{
            //video
            let fileName = "video_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".mov"
            
            StorageManager.shared.uploadMessageVideo(with: videoUrl, fileName: fileName) { [weak self] result in
                switch result{
                case .success(let urlString):
                    print("Uploaded message video: \(urlString)")
                    guard let url = URL(string: urlString), let placeholder = UIImage(systemName: "plus"),let otherUserEmail = self?.otherUserEmail else{
                        return
                    }
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)
                    let message = Message(sender: selfSender,
                                          messageId: messageId,
                                          sentDate: Date(),
                                          kind: .video(media))
                    DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: name, newMessage: message) { success in
                        if success{
                            print("sent photo message")
                        }else{
                            print("failed to send photo message")
                        }
                    }
                case .failure(let error):
                    print("Message photo upload error/Error in fetching download url for uploaded photo: \(error)")
                }
            }
        }
        
        
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else{
            return
        }
        switch message.kind{
        case .photo(let media):
            guard let imageUrl = media.url else{
                return
            }
            imageView.sd_setImage(with: imageUrl)
        default:
            break
        }
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId{
            return .link
        }
        return .secondarySystemBackground
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let sender = message.sender
        
        if sender.senderId == selfSender?.senderId{
            
            if let currentUserImageURL = self.senderPhotoURL{
                avatarView.sd_setImage(with: currentUserImageURL)
            }else{
                guard let email = getEmail() else {
                    return
                }
                let safeEmail = DatabaseManager.shared.getSafeEmail(mail: email)
                let path = "images/\(safeEmail)-profile-picture.png"
                StorageManager.shared.downloadURL(for: path) { [weak self] result in
                    
                    switch result{
                    case .success(let url):
                        self?.senderPhotoURL = url
                        DispatchQueue.main.async{
                            avatarView.sd_setImage(with: url)
                        }
                    case .failure(let error):
                        print("\(error)")
                    }
                    
                }
            }
            
            
        }else{
            
            if let otherUserImageURL = self.otherUserURL{
                avatarView.sd_setImage(with: otherUserImageURL)
            }else{
                 let email = self.otherUserEmail
                let safeEmail = DatabaseManager.shared.getSafeEmail(mail: email)
                let path = "images/\(safeEmail)-profile-picture.png"
                StorageManager.shared.downloadURL(for: path) { [weak self] result in
                    
                    switch result{
                    case .success(let url):
                        self?.otherUserURL = url
                        DispatchQueue.main.async{
                            avatarView.sd_setImage(with: url)
                        }
                    case .failure(let error):
                        print("\(error)")
                    }
                    
                }
            }
            
        }
    }
}
extension ChatViewController: MessageCellDelegate{
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else{
            return
        }
        let message = messages[indexPath.section]
        switch message.kind{
        case .photo(let media):
            guard let imageUrl = media.url else{
                return
            }
            let vc = storyboard?.instantiateViewController(withIdentifier: "photoViewer") as! PhotoViewerViewController
            vc.url = imageUrl
            navigationController?.pushViewController(vc, animated: true)
            
        case .video(let media):
            guard let videoUrl = media.url else{
                return
            }
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            present(vc,animated: true)
        default:
            break
        }
    }
}
