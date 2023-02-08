//
//  StorageManager.swift
//  Messenger
//
//  Created by Rahul Acharya on 2023-02-08.
//

import Foundation
import FirebaseStorage

/// Stop Inheritance with using Final keyword
final class StorageManager {
    
    /// Instance of StorageManager
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    /*
     /images/acharyar00071-gmail-com_picture.png
     */
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    /// Upload Picture to firebase storage and return completion with url string to download
    /// - Parameters:
    ///   - data: image png data
    ///   - fileName: Upload image name
    ///   - completion: Return Result with success (String) and failure(Error)
    public func uploadProfilePicture(with data: Data,
                                     fileName: String,
                                     completion: @escaping UploadPictureCompletion){
        storage.child("images/\(fileName)").putData(data, metadata: nil) { _, error in
            guard error == nil else {
                print("Failed to upload data to firebase for picture: \(String(describing: error))")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            
            self.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    print("Failed to get download Url: \(String(describing: url))")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print("Download Url returned: \(urlString)")
                completion(.success(urlString))
                
            }
        }
        
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        reference.downloadURL { url , error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            completion(.success(url))
        }
    }
    
    
}
