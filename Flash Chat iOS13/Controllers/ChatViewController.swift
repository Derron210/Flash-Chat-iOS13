//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore();
    
    var messages: [Message] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad();
        tableView.dataSource = self;
        tableView.delegate = self;
        navigationItem.hidesBackButton = true;
        navigationItem.title = "CHAT";
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier);
        
        loadMessages();

    }
    
    func loadMessages() {
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener {(querySnapshot, error) in
            if let e = error {
                print("There was an issue...");
            } else {
                if let snapshotDocumetns = querySnapshot?.documents {
                    self.messages = [];
                    for document in snapshotDocumetns {
                        let data = document.data();
                        if let sender = data[K.FStore.senderField] as? String, let body = data[K.FStore.bodyField] as? String {
                            self.messages.append(Message(sender: sender, body: body));
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData();
                            let indexPath = IndexPath(row: self.messages.count - 1, section: 0);
                            
                            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true);
                        }
                    }
                }
            }
        }
    }

    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
            db.collection(K.FStore.collectionName).addDocument(
                data: [K.FStore.senderField: messageSender,
                       K.FStore.bodyField: messageBody,
                       K.FStore.dateField: Date().timeIntervalSince1970]){ (error) in
                self.messageTextfield.text = "";
                if let e = error {
                    print("There was an issue saving data to firestore");
                }
            }
            
        }
        
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut();
            navigationController?.popToRootViewController(animated: true);
        } catch let signOutError as NSError {
            print(signOutError);
        }
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row];
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell;
        cell.label?.text = message.body;
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true;
            cell.rightImageView.isHidden = false;
            cell.messageBuble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple);
        }
        return cell;
    }
    
    
}

extension ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row);
    }
}
