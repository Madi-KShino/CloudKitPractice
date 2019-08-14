//
//  Entry.swift
//  CloudKitUser
//
//  Created by Madison Kaori Shino on 8/14/19.
//  Copyright © 2019 Madi S. All rights reserved.
//

import Foundation
import CloudKit

class Entry {
    
    var title: String
    var body: String
    var ckRecordID: CKRecord.ID
    let appleUserReference: CKRecord.Reference
    
    init(title: String, body: String, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), appleUserReference: CKRecord.Reference) {
        self.title = title
        self.body = body
        self.ckRecordID = ckRecordID
        self.appleUserReference = appleUserReference
    }
    
    init?(record: CKRecord) {
        guard let title = record[EntryConstants.titleKey] as? String,
        let body = record[EntryConstants.bodyKey] as? String,
        let appleUserReference = record[EntryConstants.appleRefKey] as? CKRecord.Reference,
            record.recordType == EntryConstants.typeKey
            else { return nil }
        self.title = title
        self.body = body
        self.appleUserReference = appleUserReference
        self.ckRecordID = record.recordID
    }
}

extension CKRecord {
    convenience init(entry: Entry) {
        let recordId = entry.ckRecordID
        self.init(recordType: EntryConstants.typeKey, recordID: recordId)
        self.setValue(entry.title, forKey: EntryConstants.titleKey)
        self.setValue(entry.body, forKey: EntryConstants.bodyKey)
        self.setValue(entry.appleUserReference, forKey: EntryConstants.appleRefKey)
    }
}

extension Entry: Equatable {
    static func ==(lhs: Entry, rhs: Entry) -> Bool {
        return lhs.title == rhs.title &&
        lhs.body == rhs.body &&
        lhs.ckRecordID == rhs.ckRecordID &&
        lhs.appleUserReference == rhs.appleUserReference
    }
}

struct EntryConstants {
    static let typeKey = "Entry"
    fileprivate static let titleKey = "title"
    fileprivate static let bodyKey = "body"
    fileprivate static let appleRefKey = "appleUserReference"
}
