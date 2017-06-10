//
//  SignOutController.swift
//  Shuba App
//
//  Created by Frimpong Anorchie II on 22/05/2017.
//  Copyright © 2017 Anorex Inc. All rights reserved.
//

import UIKit
import Firebase

class SignOutController: UIViewController {
    
    lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 0.6275, green: 0, blue: 0.0392, alpha: 1)
        button.setTitle("Are You Sure You Want To Leave?", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(logoutButton)
        
        logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        logoutButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    
    
    
    
    func handleLogout() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }

    }
    

