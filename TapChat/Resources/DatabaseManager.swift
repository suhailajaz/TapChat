//
//  DatabaseManager.swift
//  TapChat
//
//  Created by suhail on 30/10/23.
//

import Foundation
import FirebaseDatabase
import MessageKit

final class DatabaseManager{
    
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    private init() {}
    
}

// MARK: - Takes any path in the database and retrurns its value
extension DatabaseManager{
    public func getDataFor(path:String, completion: @escaping (Result<Any,Error>)->Void){
        database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else{
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
    
}

// MARK: - Account Management
extension DatabaseManager{
    
    ///checks if a user already exists in the realtime databse
    public func userExists(with email: String,
                           completion: @escaping ((Bool)->Void)){
        
        let safeEmail = getSafeEmail(mail: email)
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            //even if a user already exists, this key returns flase....
            guard  snapshot.value as? [String:String] != nil  else{
                completion(false)
                return
            }
            print("User with email already exists!")
            completion(true)
        }
    }
    
    ///Inserts new user to realtime databse
    public func insertUser(user: RegisterRequest,completion: @escaping (Bool)->Void){
        
        let safeEmail = getSafeEmail(mail: user.userEmail)
        
        database.child(safeEmail).setValue([
            "first_name" : user.fName,
            "last_name"  : user.lName
        ]) {[weak self] error, _ in
            guard error == nil else{
                print("Failed to write to database")
                completion(false)
                return
            }
            
            //insert the newly added user to "users" collection which conatins all the users
            self?.database.child("users").observeSingleEvent(of: .value) { snapshot in
                
                if var usersCollection = snapshot.value as? [[String:String]]{
                    //appned to users
                    let newElement = [
                        "name" : user.fName + " " +  user.lName,
                        "email" :  safeEmail
                    ]
                    usersCollection.append(newElement)
                    self?.database.child("users").setValue(usersCollection) { error, _ in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                    
                }else{
                    //create the users
                    let newCollection : [[String:String]] = [
                        [
                            "name" : user.fName + " " +  user.lName,
                            "email" : safeEmail
                        ]
                    ]
                    self?.database.child("users").setValue(newCollection) { error, _ in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
            }
        }
    }
    
    public func getAllUsers(completion: @escaping(Result<[[String:String]],Error>)->Void){
        
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let users = snapshot.value as? [[String:String]] else{
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            completion(.success(users))
        }
    }
    
    public func getSafeEmail(mail: String)->String{
        var safeEmail = mail.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
}

// MARK: - Sending Messages/ Fetching Conversations
extension DatabaseManager{
    
    ///creates a new conversation with target user email and first message sent
    public func createNewConversation(with otheruserEmail: String,name: String, firstMessage: Message, completion: @escaping (Bool) ->Void){
        
        guard let currentEmail = getEmail(), let currentName = getName() else {
            return
        }
        let safeEmail = DatabaseManager.shared.getSafeEmail(mail: currentEmail)
        
        let ref = database.child("\(safeEmail)")
        
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String:Any] else{
                completion(false)
                print("User not found")
                return
            }
            let messageDate = firstMessage.sentDate
            let dateString = ChatResource.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind{
                
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
                
            }
            let conversationId = "conversation_\(firstMessage.messageId)"
            
            //update recipient user conversation entry
            let recipientUserConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": safeEmail,
                "name": currentName,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            self?.database.child("\(otheruserEmail)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var conversations = snapshot.value as? [[String:Any]]{
                    //append
                    conversations.append(recipientUserConversationData)
                    self?.database.child("\(otheruserEmail)/conversations").setValue(conversations)
                }else{
                    //create
                    self?.database.child("\(otheruserEmail)/conversations").setValue([recipientUserConversationData])
                }
            })
            
            
            //update current user conversation entry
            let newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": otheruserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            if var conversations = userNode["conversations"] as? [[String:Any]]{
                //conversation array already exists
                //you shpuld append
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else{
                        return
                    }
                    self?.finishCreatingConversation(name: name,conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                    //  completion(true)
                }
            }else{
                //conversation array does not exist
                // create it
                userNode["conversations"] = [
                    newConversationData
                ]
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else{
                        return
                    }
                    self?.finishCreatingConversation(name: name,conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                    //completion(true)
                }
            }
            
            
        }
    }
    
    ///creates a detailed conversation node which stores the entire conversation with all the messages between the current user and the other user
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message,completion: @escaping (Bool) ->Void){
        let messageDate = firstMessage.sentDate
        let dateString = ChatResource.dateFormatter.string(from: messageDate)
        
        var message = ""
        switch firstMessage.kind{
            
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
            
        }
        
        guard let myEmail = getEmail() else{
            return
        }
        
        let safeCurrentUSerEmail = DatabaseManager.shared.getSafeEmail(mail: myEmail)
        
        let detailedMessage: [String:Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": safeCurrentUSerEmail,
            "is_read": false,
            "name": name
        ]
        let value: [String:Any] = [
            "messages":[
                detailedMessage
            ]
        ]
        database.child("\(conversationID)").setValue(value) { error, _ in
            guard error == nil else{
                completion(false)
                return
            }
            completion(true)
        }
    }
    ///Fetches and returns all the outgoing conversations for the current logged in user with his email
    public func getAllConversations(for email: String, completion: @escaping(Result<[Conversation  ],Error>)->(Void)){
        
        database.child("\(email)/conversations").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String:Any]] else{
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            let conversations: [Conversation] = value.compactMap { dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String:Any],
                      let sentDate = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else{
                    return nil
                }
                
                let latestMessageObject = LatestMessage(date: sentDate,
                                                        text: message,
                                                        isRead: isRead)
                return Conversation(id: conversationId,
                                    name: name,
                                    otherUserEmail: otherUserEmail,
                                    latestMessage: latestMessageObject)
            }
            completion(.success(conversations))
        }
    }
    
    ///Fetches all the messages for a given conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping(Result<[Message],Error>)->Void){
        
        database.child("\(id)/messages").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String:Any]] else{
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            let messages: [Message] = value.compactMap { dictionary in
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageID = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let date = ChatResource.dateFormatter.date(from: dateString) else{
                    return nil
                }
                var kind: MessageKind?
                if type == "photo" {
                    //photo
                    guard let imageUrl = URL(string: content), let placeholder = UIImage(systemName: "plus") else{
                        return nil
                    }
                    let media = Media(url: imageUrl,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: CGSize(width: 300, height: 300))
                    kind = .photo(media)
                } else if   type == "video" {
                    //photo
                    guard let videoUrl = URL(string: content), let placeholder = UIImage(systemName: "play.circle")?.withTintColor(.systemGray, renderingMode: .alwaysOriginal) else{
                        return nil
                    }
                  
                    let media = Media(url: videoUrl,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: CGSize(width: 300, height: 300))
                    kind = .video(media)
                } else{
                    //text
                    kind = .text(content)
                }
                
                guard let finalKind = kind else{
                    return nil
                }
                let sender = Sender(photoURL: "",
                                    senderId: senderEmail,
                                    displayName: name)
                return Message(sender: sender,
                               messageId: messageID,
                               sentDate: date,
                               kind: finalKind)
            }
            completion(.success(messages))
        }
    }
    
    ///sends a message to an existing conversation. Takes in a target conversation and a message
    public func sendMessage(to conversation: String,otherUserEmail: String, name: String, newMessage: Message, completion: @escaping (Bool)->Void){
        //add new message to messages
        database.child("\(conversation)/messages").observeSingleEvent(of: .value) {[weak self] snapshot in
            guard var currentMessages = snapshot.value as? [[String:Any]] else{
                completion(false)
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateString = ChatResource.dateFormatter.string(from: messageDate)
            var message = ""
            switch newMessage.kind{
                
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrlString  = mediaItem.url?.absoluteString{
                    message = targetUrlString
                }
                
                break
            case .video(let mediaItem):
                if let targetUrlString  = mediaItem.url?.absoluteString{
                    message = targetUrlString
                }
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
                
            }
            
            guard let myEmail = getEmail() else{
                return
            }
            
            let safeCurrentUSerEmail = DatabaseManager.shared.getSafeEmail(mail: myEmail)
            
            let newMessageEntry: [String:Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": safeCurrentUSerEmail,
                "is_read": false,
                "name": name
            ]
            currentMessages.append(newMessageEntry)
            self?.database.child("\(conversation)/messages").setValue(currentMessages, withCompletionBlock: { error, _ in
                guard error == nil else{
                    completion(false)
                    return
                }
                //upadate sender latest message
                self?.updateCurrentUserLatestMessage(coversationID: conversation, dateString: dateString, message: message, completion: { success in
                    if success{
                        //upadate recipient latest message
                        self?.updateRecipientUserLatestMessage(coversationID: conversation, otherUserEmail: otherUserEmail, dateString: dateString, message: message, completion: { success in
                            if success{
                                completion(true)
                            }
                            
                        })
                    }
                })
                
            })
        }
    }
    
    //updates the current user latest message
    private  func updateCurrentUserLatestMessage(coversationID: String,dateString: String,message: String, completion: @escaping (Bool)->Void){
        guard let myEmail = getEmail() else {
            completion(false)
            return
        }
        let safeMyEmail = DatabaseManager.shared.getSafeEmail(mail: myEmail)
        
        database.child("\(safeMyEmail)/conversations").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard var currentUserConversations = snapshot.value as? [[String:Any]] else{
                completion(false)
                return
            }
            
            let updateLatestMessage: [String:Any] = [
                "date": dateString,
                "is_read": false,
                "message": message
                
            ]
            var targetConversation: [String:Any]?
            var position = 0
            
            for currentUserConversation in currentUserConversations{
                if let currentID = currentUserConversation["id"] as? String, currentID == coversationID{
                    targetConversation = currentUserConversation
                    break
                }
                position += 1
            }
            targetConversation?["latest_message"] = updateLatestMessage
            guard let finalConversation = targetConversation else{
                completion(false)
                return
            }
            currentUserConversations[position] = finalConversation
            self?.database.child("\(safeMyEmail)/conversations").setValue(currentUserConversations) { error, _ in
                guard error == nil else{
                    completion(false)
                    return
                }
                completion(true)
            }
        }
    }
    //updates the recipient user latest message
    private  func updateRecipientUserLatestMessage(coversationID: String,otherUserEmail: String,dateString: String,message: String, completion: @escaping (Bool)->Void){
        
        database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard var otherUserConversations = snapshot.value as? [[String:Any]] else{
                completion(false)
                return
            }
            
            let updateLatestMessage: [String:Any] = [
                "date": dateString,
                "is_read": false,
                "message": message
                
            ]
            var targetConversation: [String:Any]?
            var position = 0
            
            for currentUserConversation in otherUserConversations{
                if let currentID = currentUserConversation["id"] as? String, currentID == coversationID{
                    targetConversation = currentUserConversation
                    break
                }
                position += 1
            }
            targetConversation?["latest_message"] = updateLatestMessage
            guard let finalConversation = targetConversation else{
                completion(false)
                return
            }
            otherUserConversations[position] = finalConversation
            self?.database.child("\(otherUserEmail)/conversations").setValue(otherUserConversations) { error, _ in
                guard error == nil else{
                    completion(false)
                    return
                }
                completion(true)
            }
        }
    }
    ///Deletes a conversation from the conversation list of the user who deleted it
    public func deleteConversation(conversationId: String,completion: @escaping (Bool)->Void){
        
        guard let email = getEmail() else{
            return
        }
        let safeEmail = DatabaseManager.shared.getSafeEmail(mail: email)
        
        let ref = database.child("\(safeEmail)/conversations")
        ref.observeSingleEvent(of: .value) { snapshot in
            if var conversations = snapshot.value as? [[String:Any]]{
                var positionToRemove = 0
                for conversation in conversations{
                    if let id = conversation["id"] as? String,
                       id == conversationId{
                        print("found conversation to delete")
                        break
                    }
                    positionToRemove += 1
                }
                conversations.remove(at: positionToRemove)
                ref.setValue(conversations) { error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    print("deleted conversation")
                    completion(true)
                }
            }
        }
    }
}
