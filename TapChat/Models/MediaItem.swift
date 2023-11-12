//
//  MediaItem.swift
//  TapChat
//
//  Created by suhail on 11/11/23.
//

import Foundation
import MessageKit

struct Media: MediaItem{
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}
