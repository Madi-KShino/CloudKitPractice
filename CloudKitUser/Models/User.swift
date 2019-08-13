//
//  User.swift
//  CloudKitUser
//
//  Created by Madison Kaori Shino on 8/13/19.
//  Copyright © 2019 Madi S. All rights reserved.
//

import Foundation
import CloudKit

class User {
    
    //Class Properties
    var email: String
    var username: String
    var password: String
    //Cloud Kit Properties
    var ckrecordID: CKRecord.ID?
    let appleUserReference: CKRecord.Reference
    
    //Designated Init
    init(email: String, username: String, password: String, appleUserReference: CKRecord.Reference) {
        self.email = email
        self.username = username
        self.password = password
        self.appleUserReference = appleUserReference
    }
    
    //Init a User from a Record
    init?(record: CKRecord) {
        guard let username = record[UserConstants.usernameKey] as? String,
        let email = record[UserConstants.emailKey] as? String,
        let password = record[UserConstants.passwordKey] as? String,
        let appleUserReference = record[UserConstants.appleUserReferenceKey] as? CKRecord.Reference
            else { return nil }
        self.username = username
        self.email = email
        self.password = password
        self.appleUserReference = appleUserReference
        self.ckrecordID = record.recordID
    }
}

//Init a Record from a User
extension CKRecord {
    convenience init(user: User) {
        let recordID = user.ckrecordID ?? CKRecord.ID(recordName: UUID().uuidString)
        self.init(recordType: UserConstants.recordTypeKey, recordID: recordID)
        self.setValue(user.email, forKey: UserConstants.emailKey)
        self.setValue(user.username, forKey: UserConstants.usernameKey)
        self.setValue(user.password, forKey: UserConstants.passwordKey)
        self.setValue(user.appleUserReference, forKey: UserConstants.appleUserReferenceKey)
    }
}

//Magic Strings for Record Keys
struct UserConstants {
    static let recordTypeKey = "User"
    fileprivate static let usernameKey = "username"
    fileprivate static let emailKey = "email"
    fileprivate static let passwordKey = "password"
    fileprivate static let appleUserReferenceKey = "appleUserReference"
}
