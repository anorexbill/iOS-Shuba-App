//
//  CrowdController.swift
//  Shuba App
//
//  Created by Frimpong Anorchie II on 22/05/2017.
//  Copyright © 2017 Anorex Inc. All rights reserved.
//

import UIKit
import Firebase

class CrowdController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
     var Username = String()
    var chatMessages = [ChatMessages]()
    
    lazy var inputTextField: UITextField = {
        
        let inputTextField = UITextField()
            let textField = UITextField()
            textField.placeholder = "Enter message..."
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.delegate = self
            return textField
    }()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 58, 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 50, 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        navigationItem.title = "Crowd Messages"
        
        setupInputComponents()
        observerMessages()
        getUser()
        
        setupKeyboardObservers()
    }
    
    func setupKeyboardObservers() {
       NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        
       NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
    }
    
    func handleKeyboardWillShow(notification: NSNotification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    func handleKeyboardWillHide(notification: NSNotification) {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerViewBottomAnchor?.constant = -49
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }

    }

    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = chatMessages[indexPath.item]
        let texter = message.name!
        
        var newDate = String()
        if let date = message.timestamp?.doubleValue {
            let timestampDate = Date(timeIntervalSinceReferenceDate: date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy 'at' HH:mm"
        newDate = dateFormatter.string(from: timestampDate as Date)
        }
        
//        let forumItems = [message.timestamp]
//        var date = Date()
//        for i in 0 ..< forumItems.count {
//            
//            if forumItems[i] != nil {
//                date = Date(timeIntervalSince1970: TimeInterval.init(forumItems[i]!))
//            
//            }else{
//                let main_date : Double = Double.init("\(String(describing: forumItems[i]))00")!
//                let la_date : Double = main_date / 100000
//                date = Date(timeIntervalSince1970: TimeInterval.init(la_date))
//            }
//        
//        }
        
        
        let attributedText = NSMutableAttributedString(string: texter, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightBlack)])
        
        attributedText.append(NSAttributedString(string: "\n\(String(describing: message.msg!))", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)]))
        
        attributedText.append(NSAttributedString(string: "\n\n\(newDate)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 10, weight: UIFontWeightSemibold)]))
        
       cell.textView.attributedText =  attributedText

        setupCell(cell: cell, message: message)
        
        //lets modify the bubbleview
        cell.bubbleWidthAnchor?.constant = estimatedFrameForText(text: String(describing: attributedText)).width + 20
        
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: ChatMessages) {
    
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            //outgoing blue
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.shubaLogoView.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        }else {
            //incoming grey
            cell.bubbleView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            cell.textView.textColor = UIColor.black
            cell.shubaLogoView.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
    
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        //get estimated height
        if let text = chatMessages[indexPath.item].msg {
            height = estimatedFrameForText(text: text).height + 55
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimatedFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
        
    }
    
    func observerMessages() {
        
        FIRDatabase.database().reference().child("crowd").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                
                let chat = ChatMessages()
                chat.setValuesForKeys(dictionary)
                
                self.chatMessages.append(chat)
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
                
            }
            
        }, withCancel: nil)
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    func setupInputComponents() {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        //ios9 constraints anchors
        //x,y,w,z
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        containerViewBottomAnchor =  containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -49)
        
       containerViewBottomAnchor?.isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        //x,y,w,z
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(inputTextField)
        //x,y,w,z
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//        inputTextField.widthAnchor.constraint(equalToConstant: 100).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        //x,y,w,z
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
//        getUser()
    }
    
    func getUser(){
        let uid = FIRAuth.auth()?.currentUser?.uid
        FIRDatabase.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject]{
                
                self.Username = (dict["fullName"] as! String?)!
            }
        })
    }
    
    func handleSend() {
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        let ref = FIRDatabase.database().reference().child("crowd")
        let childRef = ref.childByAutoId()
        let time = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        let fullMessage = inputTextField.text!
        let values = ["fromId": uid!, "msg": fullMessage, "name": Username, "timestamp": time] as [String : Any]
        childRef.updateChildValues(values)
        
        self.inputTextField.text = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}











