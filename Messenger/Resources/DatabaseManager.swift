//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Rahul Acharya on 2023-02-01.
//

import Foundation
import FirebaseDatabase
import UIKit

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
}

// MARK: - Account Management
extension DatabaseManager {
    
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)) {
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { snapShot in
            guard ((snapShot.value as? String) != nil) else {
                completion(false)
                return
            }
        }
        completion(true)
    }
    
    /// Insert new user to database
    /// - Parameter user: New User
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName,
        ]) { error, _ in
            guard error == nil else {
                print("Failed to write to database: \(String(describing: error))")
                completion(false)
                return
            }
            self.database.child("users").observeSingleEvent(of: .value) { snapshot in
                if var userCollection = snapshot.value as? [[String: String]] {
                    // append to user dictionary
                    let newElement =   [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.safeEmail
                    ]
                    
                    userCollection.append(newElement)
                    
                    self.database.child("users").setValue(userCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                } else {
                    // create that array
                    let newCollection: [[String: String]] = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                        ]
                    ]
                    self.database.child("users").setValue(newCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
            }
        }
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
    
    /*
     [
     [
     "name":
     "safe_email":
     ],
     [
     "name":
     "safe_email":
     ],
     
     ]
     
     */
    
    
}



// MARK: - Sending Messaging / Conversation
extension DatabaseManager {
    /*
     
     "dasdfa" {
     "message": [
     {
     "id": String,
     "type": text, photo, video,
     "content": String,
     "date": Date(),
     "sender_email": String,
     "isRead": true/false,
     }
     ]
     }
     
     
     Conversation ==> [
     [
     "conversation_id":
     "other_user_email":
     "latest_message": => {
     "date": Date()
     "latest_message": "message"
     "is_read": true/false
     }
     ]
     ]
     
     */
    
    /// Create new conversation with target user email and first message sent
    /// - Parameters:
    ///   - otherUserEmail: Receive email address
    ///   - firstMessage: First Message
    ///   - completion: Success check
    public func createNewConversation(with otherUserEmail: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        let ref = database.child(safeEmail)
        
        ref.observeSingleEvent(of: .value) { snapshot in
   
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("user not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
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
            
            
            let conversationID = "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String : Any] = [
                "id": conversationID,
                "other_user_email": otherUserEmail,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // conversations array exists of current user
                // you should append
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationID: conversationID,
                                                    firstMessage: firstMessage,
                                                    completion: completion)
                }
                
            } else {
                // conversations array does not exists of current user
                // Create it
                userNode["conversations"] = [newConversationData]
                
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationID: conversationID,
                                                    firstMessage: firstMessage,
                                                    completion: completion)
                }
            }
        }
    }
    
    private func finishCreatingConversation(conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void ){
//        {
//            "id": String,
//            "type": text, photo, video,
//            "content": String,
//            "date": Date(),
//            "sender_email": String,
//            "isRead": true/false
//        }
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        
        var message = ""
        
        switch firstMessage.kind {
            
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
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        let collectionMessage: [String : Any] = [
            "id"            : firstMessage.messageId,
            "type"          : firstMessage.kind.messageKindString,
            "content"       : message,
            "date"          : dateString,
            "sender_email"  : currentUserEmail,
            "is_read"       : false
        ]
        
        let value: [String: Any] = ["messages": [collectionMessage]]
        
        print("adding convo: \(conversationID)")
        
        database.child("\(conversationID)").setValue(value) { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    /// Fetches and return all conversations for the user
    /// - Parameters:
    ///   - email: User Email
    ///   - completion: success case
    public func getAllConversation(for email: String, completion: @escaping (Result<String, Error>) -> Void){
        
    }
    
    /// Get all Messages for a given Conversation
    /// - Parameters:
    ///   - id: user id
    ///   - completion: success case
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    /// Send Message with target
    /// - Parameters:
    ///   - conversation: Conversation
    ///   - message: Message
    public func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void) {
        
    }
}


struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    var  safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        return safeEmail
    }
    var profilePictureFileName: String {
        // acharyar00071-gmail-com_picture.png
        return "\(safeEmail)_profile_picture.png"
    }
    
}
