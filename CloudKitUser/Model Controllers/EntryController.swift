//
//  EntryController.swift
//  CloudKitUser
//
//  Created by Madison Kaori Shino on 8/14/19.
//  Copyright © 2019 Madi S. All rights reserved.
//

import Foundation
import CloudKit

class EntryController {
    
    //Singleton
    static let sharedInstance = EntryController()
    
    //Source of Truth
    var entries: [Entry] = []
    
    //Database
    private let publicDatabase = CKContainer.default().privateCloudDatabase
    
    //Crud Functions
    func save(entry: Entry, completion: @escaping(Bool) -> Void) {
        let record = CKRecord(entry: entry)
        publicDatabase.save(record) { (record, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            self.entries.append(entry)
            completion(true)
            print("Entry with ID: \(entry.ckRecordID) Sucessfully Saved")
        }
    }
    
    func createEntry(with title: String, body: String, completion: @escaping(Bool) -> Void) {
        guard let appleuserRef = UserController.sharedInstance.currentUser?.appleUserReference else { completion(false); return }
        let entry = Entry(title: title, body: body, appleUserReference: appleuserRef)
        save(entry: entry) { (success) in
            completion(success)
            print("Entry with ID: \(entry.ckRecordID) Sucessfully Created")
        }
    }
    
    func fetchEntries(completion: @escaping(Bool) -> Void) {
        guard let appleUserRef = UserController.sharedInstance.currentUser?.appleUserReference else { completion(false); return }
        let predicate = NSPredicate(format: "appleUserReference == %@", appleUserRef)
        let query = CKQuery(recordType: EntryConstants.typeKey, predicate: predicate)
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            guard let records = records else { completion(false); return }
            let entries = records.compactMap({Entry(record: $0)})
            self.entries = entries
            completion(true)
            print("Entries for User with ID: \(appleUserRef) Sucessfully Fetched")
        }
    }
    
    func update(entry: Entry, title: String, body: String, completion: @escaping(Bool) -> Void) {
        entry.title = title
        entry.body = body
        let record = CKRecord(entry: entry)
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.queuePriority = .high
        operation.qualityOfService = .userInteractive
        operation.completionBlock = {
            completion(true)
        }
        publicDatabase.add(operation)
        print("Entry with ID: \(entry.ckRecordID) Sucessfully Updated")
    }
    
    func delete(entry: Entry, completion: @escaping(Bool, String?) -> Void) {
        let recordID = entry.ckRecordID
        publicDatabase.delete(withRecordID: recordID) { (recordID, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) \n---\n \(error)")
                completion(false, error.localizedDescription)
                return
            }
            completion(true, error?.localizedDescription)
            print("Entry with ID: \(entry.ckRecordID) Sucessfully Deleted")
        }
        guard let index = self.entries.firstIndex(of: entry) else { return }
        self.entries.remove(at: index)
    }
    
    func createShare(entry: Entry, completion: @escaping(CKShare?, CKContainer?, Error?) -> Void) {
        //Create the rood record from the entry, create share from the root record
        let rootRecord = CKRecord(entry: entry)
//        let testrec = CKRecordZone(zoneID: <#T##CKRecordZone.ID#>)
        let shareRecord = CKShare(rootRecord: rootRecord)
        //root record has ref to share record, so both will need to be modified/updated
        let operation = CKModifyRecordsOperation(recordsToSave: [shareRecord, rootRecord], recordIDsToDelete: nil)
        operation.perRecordCompletionBlock = { (record, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) \n---\n \(error)")
                completion(nil, nil, error)
            }
        }
        operation.modifyRecordsCompletionBlock = { (savedRecords, deletedRecordIDs, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) \n---\n \(error)")
                completion(nil, nil, error)
            } else {
                completion(shareRecord, CKContainer.default(), nil)
            }
        }
        publicDatabase.add(operation)
    }
    
    func createZone(completionHandler:@escaping (CKRecordZone?, Error?)->Void) {
        let customZone = CKRecordZone(zoneName: "ShareZone")
        publicDatabase.save(customZone, completionHandler: ({returnRecord, error in
            completionHandler(returnRecord, error)
        }))
    }
}
