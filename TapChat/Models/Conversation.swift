//
//  Conversation.swift
//  TapChat
//
//  Created by suhail on 09/11/23.
//

import Foundation

struct Conversation{
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage{
    let date: String
    let text: String
    let isRead: Bool
}
