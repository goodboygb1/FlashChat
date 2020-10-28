//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    let db = Firestore.firestore()
    
    var message : [Message] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.message = []
        navigationItem.hidesBackButton = true
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        
        loadMessage()
    }
    
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email  {
            if messageBody != "" {
                
                let message :[String : Any] = [K.FStore.bodyField : messageBody,
                                               K.FStore.senderField : messageSender,
                                               K.FStore.dateField : Date().timeIntervalSince1970
                ]
                
                db.collection(K.FStore.collectionName).addDocument(data: message) { (error) in
                    if let e = error {
                        print("error while saveing data to fire store \(e)")
                    } else {
                        print("saving success")
                    }
                }
            }
            
        }
         messageTextfield.text = ""
    }
    
    
    @IBAction func logOutPressed(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
}


extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return message.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messages = message[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.lable.text = messages.body
        print("Add data to cell")
        
        if messages.sender == Auth.auth().currentUser?.email { // me user
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.lable.textColor = UIColor(named: K.BrandColors.purple)
            print("this is me")
        } else { // another user
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.lable.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        return cell
    }
    
    func loadMessage()  {
        
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { (querySnapshot, error) in
                
                self.message = []
                if let e = error {
                    print("error while loading data \(e)")
                } else {
                    if let snapShotDocument = querySnapshot?.documents { // array of object
                        for doc in snapShotDocument { // ได้รับ data ใน type dictionary
                            
                            let data = doc.data()
                            if let messageSender = data[K.FStore.senderField] as? String ,let body = data[K.FStore.bodyField] as? String {
                                let newMessage = Message(sender: messageSender, body: body)
                                
                                self.message.append(newMessage)
                                print("append success")
                                
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    let indexPath = IndexPath(row: self.message.count-1, section: 0)
                                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                                   
                                }
                            }
                        }
                    }
                }
        }
        
    }
}




class ShowAddressViewController:UIViewController{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressTableView: UITableView!
    
    var name: String?
    var addresses: [Address] = []
    var db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = name!
        addressTableView.dataSource = self
        //addressTableView.register(UINib(nibName: K.identifierForTableView.nibNameAddress, bundle: nil), forCellReuseIdentifier: K.identifierForTableView.identifierAddress)
        loadAddressData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    @IBAction func addAddressPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: K.segue.goToEditAddressSegue, sender: self)
    }
    
    func loadAddressData(){
        if let emailSender = Auth.auth().currentUser?.email{
            db.collection(K.tableName.addressTableName).whereField(K.sender, isEqualTo: emailSender).getDocuments { (querySnapshot, error) in
                self.addresses = []
                if let e = error{
                    print("error while loading name in show address page: \(e.localizedDescription)")
                }else{
                   if let snapShotDocument = querySnapshot?.documents{
                        for doc in snapShotDocument{
                            let data = doc.data()
                            let doc_id = doc.documentID
                            if let firstName = data[K.firstName] as? String, let lastName = data[K.surname] as? String, let phoneNumber = data[K.phoneNumber] as? String
                                , let addressDetail = data[K.addressDetail] as? String, let district = data[K.district] as? String
                                , let province = data[K.province] as? String, let postCode = data[K.postCode] as? String{
                                let newAddress = Address(firstName: firstName,lastName: lastName, phoneNumber: phoneNumber, addressDetail: addressDetail, district: district, province: province, postCode: postCode,docID: doc_id)
                                self.addresses.append(newAddress)
                                
                                DispatchQueue.main.async {
                                    self.addressTableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
        print("Successfully address loaded to array")
    }

}

extension ShowAddressViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let address = addresses[indexPath.row]
        let addressCell = addressTableView.dequeueReusableCell(withIdentifier: K.identifierForTableView.identifierAddress) as! AddressCell
        addressCell.firstNameLabel.text = address.firstName
        addressCell.lastNameLabel.text = address.lastName
        addressCell.phoneLabel.text = address.phoneNumber
        addressCell.addressDetailLabel.text = address.addressDetail
        addressCell.districtLabel.text = address.district
        addressCell.provinceLabel.text = address.province
        addressCell.postCodeLabel.text = address.postCode
        addressCell.documentIDLabel.text = address.docID
        addressCell.delegate = self
        return addressCell
    }
}
