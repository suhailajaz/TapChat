//
//  Message.swift
//  TapChat
//
//  Created by suhail on 01/11/23.
//

import Foundation
import MessageKit

struct Message: MessageType{
   
   public var sender: SenderType
   public var messageId: String
   public var sentDate: Date
   public var kind: MessageKind
}
