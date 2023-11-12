//
//  Enums.swift
//  TapChat
//
//  Created by suhail on 02/11/23.
//

import Foundation

public enum StorageErrors: Error{
    case failedToUpload
    case failedToGetDownloadUrl
}

public enum DatabaseErrors: Error{
    case failedToFetch
}
