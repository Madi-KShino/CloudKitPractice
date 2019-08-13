//
//  WelcomeViewController.swift
//  CloudKitUser
//
//  Created by Madison Kaori Shino on 8/13/19.
//  Copyright © 2019 Madi S. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    //Outlets
    @IBOutlet weak var welcomeLabel: UILabel!
    
    //Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        welcomeLabel.text = "Welcome\n\(UserController.sharedInstance.currentUser?.username ?? "")"
    }
}
