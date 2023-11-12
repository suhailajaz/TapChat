//
//  ChatResource.swift
//  TapChat
//
//  Created by suhail on 08/11/23.
//

import Foundation

class ChatResource {
    
    static let shared = ChatResource()
    
    public static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    
    public func createMessageId(otherUserEmail: String)->String?{
        guard let currentUserEmail = getEmail() else{
            return nil
        }
        let safeCurrentEmail = DatabaseManager.shared.getSafeEmail(mail: currentUserEmail)
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)-\(safeCurrentEmail)-\(dateString)"
        return newIdentifier
    }
    
}
