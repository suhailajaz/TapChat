//
//  MessageExtensions.swift
//  TapChat
//
//  Created by suhail on 08/11/23.
//

import Foundation
import MessageKit

extension MessageKind{
   
    var messageKindString: String{
        
        switch self{
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
           
    }
}
