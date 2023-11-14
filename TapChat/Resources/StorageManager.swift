//
//  StorageManager.swift
//  TapChat
//
//  Created by suhail on 02/11/23.
//

import Foundation
import FirebaseStorage

final class StorageManager{
    
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    
    ///uploads picture to firebase storage and retuns completion with url string to download
    public typealias UploadPictureCompletion = (Result<String,Error>)->Void
    
    public func uploadProfilepicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion){
        storage.child("images/\(fileName)").putData(data, metadata: nil) {[weak self] metadata, error in
            guard error == nil else{
                print("failed to upload profile image data to firebase")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url else{
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download url returned: \(urlString)")
                completion(.success(urlString))
            }
            
        }
    }
    ///uploads picture to firebase storage that will be sent inside a chat
    public func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion){
        storage.child("message_images/\(fileName)").putData(data, metadata: nil) { [weak self] metadata, error in
            guard error == nil else{
                print("failed to upload coversation image data to firebase")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("message_images/\(fileName)").downloadURL { url, error in
                guard let url = url else{
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download url returned: \(urlString)")
                completion(.success(urlString))
            }
            
        }
    }
    
    ///uploads video to firebase storage that will be sent inside a chat
    public func uploadMessageVideo(with videoFileURL: URL, fileName: String, completion: @escaping UploadPictureCompletion){
        storage.child("message_videos/\(fileName)").putFile(from: videoFileURL, metadata: nil) { [weak self] metadata, error in
            guard error == nil else{
                print("failed to upload video file to firebase")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("message_videos/\(fileName)").downloadURL {  url, error in
                guard let url = url else{
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download url returned: \(urlString)")
                completion(.success(urlString))
            }
            
        }
    }
    func downloadURL(for path: String,completion: @escaping (Result<URL,Error>) -> Void){
        print("%%%%%%%%%%")
        print(path)
        let imageReference = storage.child(path)
        
        imageReference.downloadURL { url, error in
            guard let url = url, error == nil else{
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            completion(.success(url))
        }
    }
    
}
