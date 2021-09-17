//
//  SessionDetailViewController.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 14.09.21.
//

import UIKit

class SessionDetailViewController: UIViewController {

    @IBOutlet var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var textView: UITextView!
    @IBOutlet var tableView: UITableView!
    var userId = "1234"
    
    var messages = [
        SessionChatMessage(text: "Hello there, how's it going?", userId: "1234"),
        SessionChatMessage(text: "Hi there! 😅 ", userId: "2456"),
        SessionChatMessage(text: "🍎 Was good bitch", userId: "1234"),
        SessionChatMessage(text: "I dey oh, just dey go jejerity", userId: "2456"),
        SessionChatMessage(text: "Wetin dey Sup na", userId: "2456"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "SessionMessageCell", bundle: nil), forCellReuseIdentifier: "SessionMessageCell")
        addGestureRecognizer()
        navigationItem.rightBarButtonItem = getRightBarView()
        navigationItem.titleView = getTitleView()
        textView.delegate = self
        configureTextView()
    }
    

    func configureTextView() {
        textView.layer.cornerRadius = 15
        textView.keyboardDistanceFromTextField = 30
    }
    
    func addGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        tableView.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        textView.endEditing(true)
    }
    
    func getRightBarView() -> UIBarButtonItem {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fillEqually
        view.spacing = 30
  
        let video = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        video.image = UIImage(systemName: "camera.fill")
        
        let audio = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        audio.image = UIImage(systemName: "phone.fill")
        
        
        view.frame =  CGRect(x: 0, y: 0, width: 150, height: 50)
        view.addArrangedSubview(video)
        view.addArrangedSubview(audio)
        
        return UIBarButtonItem(customView: view)
    }
    
    func getTitleView() -> UIStackView {
        let view = UIStackView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fill
        view.spacing = 10
  
        let avatar = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        avatar.image = UIImage(named: "avi1")
        avatar.layer.cornerRadius = 23
        avatar.clipsToBounds = true
        
        let label = UILabel()
        label.text = "Mary Agida"
        label.textColor = .white
    
        view.addArrangedSubview(avatar)
        view.addArrangedSubview(label)

        
        NSLayoutConstraint.activate([
            avatar.widthAnchor.constraint(equalToConstant: 42),
            avatar.heightAnchor.constraint(equalToConstant: 42),
            view.widthAnchor.constraint(equalToConstant: 250)
        ])
        
        return view
    }

    @IBAction func sendButtonPressed(_ sender: Any) {
        let message = textView.text
        messages.append(SessionChatMessage(text: message!, userId: userId))
        textView.text = ""
        textViewHeightConstraint.constant = 35
        tableView.reloadData()
//        performSegue(withIdentifier: "MakeAudioCall", sender: self)
    }
    
}


extension SessionDetailViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}


extension SessionDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionMessageCell", for: indexPath) as! SessionMessageCell

        cell.chatTextView.text = messages[indexPath.row].text
        cell.chatBox.backgroundColor = userId ==  messages[indexPath.row].userId ? UIColor(named: "App Teal") : .white
        cell.chatTextView.textColor = userId ==  messages[indexPath.row].userId ?  .white : UIColor(named: "App Teal")
        cell.chatBox.layer.borderWidth = 1
        cell.chatBox.layer.borderColor = UIColor(named: "App Teal")?.cgColor
        
        if (userId != messages[indexPath.row].userId) {
            cell.leadingConstraint.isActive = false
            NSLayoutConstraint.activate([
                cell.chatBox.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor, constant: 10),
            ])
        }
        
        return cell
    }
    
}

//MARK: - Text View Delegate
extension SessionDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textView.sizeToFit()
        textViewHeightConstraint.constant = textView.contentSize.height
    }
    
}


