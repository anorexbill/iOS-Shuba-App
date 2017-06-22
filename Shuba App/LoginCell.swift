//
//  LoginCell.swift
//  Shuba App
//
//  Created by Frimpong Anorchie II on 19/05/2017.
//  Copyright © 2017 Anorex Inc. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginCell: UICollectionViewCell {

    let knustImageView: UIImageView = {
        let image = UIImage(named: "Knust1")
        let imageView = UIImageView(image: image)
        return imageView
    }()
    
    let shubaImageView: UIImageView = {
        let image = UIImage(named: "red shuba text")
        let imageView = UIImageView(image: image)
        return imageView
    }()
    
    let emailTextField: LeftPaddedTextField = {
        let textField = LeftPaddedTextField()
        textField.placeholder = "Enter Email"
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1
        textField.keyboardType = .emailAddress
        textField.textColor = UIColor(red: 0.6275, green: 0, blue: 0.0392, alpha: 1)
        return textField
    }()
    
    let passwordTextField: LeftPaddedTextField = {
        let textField = LeftPaddedTextField()
        textField.placeholder = "Enter Password"
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1
        textField.textColor = UIColor(red: 0.6275, green: 0, blue: 0.0392, alpha: 1)
        textField.isSecureTextEntry = true
        return textField
    }()
    
   lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 0.6275, green: 0, blue: 0.0392, alpha: 1)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white
        button.setTitle("Not A Member Yet? Join Us", for: .normal)
        button.setTitleColor(UIColor(red: 0.6275, green: 0, blue: 0.0392, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(handleMoveRegister), for: .touchUpInside)
        return button
    }()
    
    var loginController: LoginController?
    
    
    func handleLogin() {
   guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is invalid")
            return
        }
        
        if (email.isEmpty || password.isEmpty) {
            self.loginController?.saveNotice(userMessage: "Fields required to log in")
            return
        }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            self.loginController?.activity()
            if error != nil {
                print(error!)
                
                self.loginController?.saveNotice(userMessage: "You were unable to log in, Sorry")
                
                return
            }
            self.loginController?.finishLoggingIn()
            
        })
        
    }
    
    
    func handleMoveRegister() {
        self.loginController?.moveToRegisterPage()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        addSubview(knustImageView)
        addSubview(shubaImageView)
        addSubview(emailTextField)
        addSubview(passwordTextField)
        addSubview(loginButton)
        addSubview(registerButton)
       
        
        _ = knustImageView.anchor(centerYAnchor, left: nil, bottom: nil, right: nil, topConstant: -230, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 120, heightConstant: 130)
        
        knustImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        _ = shubaImageView.anchor(knustImageView.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 4, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 130, heightConstant: 50)
        
        shubaImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        _ = emailTextField.anchor(shubaImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 8, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 40)
        
        _ = passwordTextField.anchor(emailTextField.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 8, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 40)
        
        _ = loginButton.anchor(passwordTextField.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 8, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 40)
        
       _ = registerButton.anchor(loginButton.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 130, leftConstant: 92, bottomConstant: 0, rightConstant: 92, widthConstant: 0, heightConstant: 20)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LeftPaddedTextField: UITextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width + 10, height: bounds.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width + 10, height: bounds.height)
    }
    
}




