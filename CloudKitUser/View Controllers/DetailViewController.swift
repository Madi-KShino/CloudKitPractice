//
//  DetailViewController.swift
//  CloudKitUser
//
//  Created by Madison Kaori Shino on 8/14/19.
//  Copyright © 2019 Madi S. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    //Properties
    var entry: Entry?
    
    //Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    
    //Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        titleTextField.delegate = self
    }
    
    //Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let title = titleTextField.text, title != "",
            let body = bodyTextView.text, body != ""
            else { return }
        if let entry = entry {
            EntryController.sharedInstance.update(entry: entry, title: title, body: body) { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }else {
                    print("Error Updating Entry")
                }
            }
        } else {
            EntryController.sharedInstance.createEntry(with: title, body: body) { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    print("Error Creating Entry")
                }
            }
        }
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        titleTextField.text = ""
        bodyTextView.text = ""
    }
    
    func updateViews() {
        guard let entry = entry else { return }
        titleTextField.text = entry.title
        bodyTextView.text = entry.body
    }
}

extension DetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
