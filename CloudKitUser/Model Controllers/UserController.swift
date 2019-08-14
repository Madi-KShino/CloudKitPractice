//
//  UserController.swift
//  CloudKitUser
//
//  Created by Madison Kaori Shino on 8/13/19.
//  Copyright © 2019 Madi S. All rights reserved.
//

import Foundation
import CloudKit

class UserController {
    
    //Singleton
    static let sharedInstance = UserController()
    
    //Source of Truth
    var currentUser: User? {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .userCreated, object: nil)
            }
        }
    }
    
    //Database
    var database = CKContainer.default().privateCloudDatabase
    
    //CRUD Functions
    func createUserWith(email: String, username: String, password: String, completion: @escaping (Bool) -> Void) {
        CKContainer.default().fetchUserRecordID { (appleUserRefID, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            guard let appleUserRefID = appleUserRefID else { completion(false); return }
            let appleUserRef = CKRecord.Reference(recordID: appleUserRefID, action: .deleteSelf)
            let user = User(email: email, username: username, password: password, appleUserReference: appleUserRef)
            let userRecord = CKRecord(user: user)
            self.database.save(userRecord, completionHandler: { (record, error) in
                if let error = error {
                    print("Error in \(#function): \(error.localizedDescription) \n---\n \(error)")
                    completion(false)
                    return
                }
                guard let record = record else { completion(false); return }
                guard let user = User(record: record) else { completion(false); return }
                self.currentUser = user
                completion(true)
                print("Successfully Created User with AppleUserReferenceID: \(appleUserRefID)")
            })
        }
    }
    
    func fetchCurrentUser(completion: @escaping (Bool) -> Void) {
        CKContainer.default().fetchUserRecordID { (appleUserReferenceID, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            guard let appleUserRefID = appleUserReferenceID else { completion(false); return }
            let appleUserReference = CKRecord.Reference(recordID: appleUserRefID, action: .deleteSelf)
            let predicate = NSPredicate(format: "appleUserReference == %@", appleUserReference)
            let query = CKQuery(recordType: UserConstants.recordTypeKey, predicate: predicate)
            self.database.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
                if let error = error {
                    print("Error in \(#function): \(error.localizedDescription) \n---\n \(error)")
                    completion(false)
                    return
                }
                guard let records = records,
                let firstRecord = records.first,
                let currentUser = User(record: firstRecord)
                    else { completion(false); return }
                self.currentUser = currentUser
                completion(true)
                print("Successfully Fetched User with AppleUserReferenceID: \(appleUserRefID)")
            })
        }
    }
    
    func updateUser() {
        
    }
    
    func deleteUser() {
        
    }  
}
