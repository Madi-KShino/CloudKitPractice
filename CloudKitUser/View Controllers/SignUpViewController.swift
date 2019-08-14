//
//  SignUpViewController.swift
//  CloudKitUser
//
//  Created by Madison Kaori Shino on 8/13/19.
//  Copyright © 2019 Madi S. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    //Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    //Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        UserController.sharedInstance.fetchCurrentUser { (success) in
            if success {
                print("User Fetched")
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserPosted), name: .userCreated, object: nil)
    }
    
    //Actions
    @IBAction func signUpButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text,
            let username = usernameTextField.text,
            let password = passwordTextField.text
            else { return }
        UserController.sharedInstance.createUserWith(email: email, username: username, password: password) { (success) in
            if success {
                print("User Created")
            }
        }
    }
    
    //Helper Functions
    @objc func handleUserPosted() {
        guard UserController.sharedInstance.currentUser != nil else { return }
        self.performSegue(withIdentifier: "toWelcomeVC", sender: self)
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
