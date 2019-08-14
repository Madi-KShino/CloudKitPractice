//
//  EntryListTableViewController.swift
//  CloudKitUser
//
//  Created by Madison Kaori Shino on 8/14/19.
//  Copyright © 2019 Madi S. All rights reserved.
//

import UIKit
import CloudKit

class EntryListTableViewController: UITableViewController {
    
    //Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Welcome \(UserController.sharedInstance.currentUser?.username ?? "")"
        fetchEntries()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.reloadData()
    }
    
    //Helper Functions
    func fetchEntries() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        EntryController.sharedInstance.fetchEntries { (success) in
            if success {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                print("Unable to fetch entries")
                self.title = "Error Loading"
            }
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }

    //Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EntryController.sharedInstance.entries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath)
        let entry = EntryController.sharedInstance.entries[indexPath.row]
        cell.textLabel?.text = entry.title
        cell.detailTextLabel?.text = entry.body
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let entry = EntryController.sharedInstance.entries[indexPath.row]
            EntryController.sharedInstance.delete(entry: entry) { (success, error) in
                if success {
                    print("Deleted Entry")
                }
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let shareContextualAction = UIContextualAction(style: UIContextualAction.Style.normal, title: "Share") { (action, view, nil) in
            //Create Cloud sharing Controller
            let cloudSharingController = UICloudSharingController { (controller, completion: @escaping (CKShare?, CKContainer?, Error?) -> Void) in
                //Call Share Function
                let entry = EntryController.sharedInstance.entries[indexPath.row]
                EntryController.sharedInstance.createShare(entry: entry, completion: completion)
            }
            cloudSharingController.availablePermissions = [.allowReadWrite, .allowPrivate]
            DispatchQueue.main.async {
                self.present(cloudSharingController, animated: true)
            }
        }
        shareContextualAction.backgroundColor = #colorLiteral(red: 0.1470449269, green: 0.4723882079, blue: 0.4497296214, alpha: 1)
        let configuration = UISwipeActionsConfiguration(actions: [shareContextualAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "updateEntry" {
            guard let destinationVC = segue.destination as? DetailViewController else { return }
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let entry = EntryController.sharedInstance.entries[indexPath.row]
            destinationVC.entry = entry
        }
    }
}
    

extension EntryListTableViewController: UICloudSharingControllerDelegate {
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        print("Error Sharing: \(error.localizedDescription) \n---\n \(error)")
    }
    
    func itemTitle(for csc: UICloudSharingController) -> String? {
        return "Share Entry"
    }
}
