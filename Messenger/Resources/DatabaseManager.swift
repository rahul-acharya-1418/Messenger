//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Rahul Acharya on 2023-02-01.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
   
 
}

// MARK: - Account Management
extension DatabaseManager {
    
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)) {
        database.child(email).observeSingleEvent(of: .value) { snapShot in
            guard ((snapShot.value as? String) != nil) else {
                completion(false)
                return
            }
        }
        completion(true)
        
    }
    
    /// Insert new user to database
    /// - Parameter user: New User
    public func insertUser(with user: ChatAppUser) {
        database.child(user.emailAddress).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName,
        ])
    }
}


struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
//    let profilePictureUrl: String
    
}
