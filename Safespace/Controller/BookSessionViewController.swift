//
//  BookSessionViewController.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 13.09.21.
//

import UIKit

class BookSessionViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var textView: UITextView!
    
    let sessions: [Session] = [
        Session(from: "11:00", to: "12:00", day: "13/04/2021"),
        Session(from: "12:00", to: "13:00", day: "13/04/2021"),
        Session(from: "13:00", to: "14:00", day: "13/04/2021"),
        Session(from: "14:00", to: "15:00", day: "13/04/2021"),
        Session(from: "15:00", to: "16:00", day: "13/04/2021"),
        Session(from: "16:00", to: "17:00", day: "13/04/2021"),
        Session(from: "17:00", to: "18:00", day: "13/04/2021"),
    ]
    
    let cellIdentifier = "SessionListTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SessionListTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.backgroundColor = .white
        textView.text = """
            Select a time in Mary’s calendar.
        Since this is your first time you may select a maximum of 2 times
        """
    }

}

//MARK: - UITableViewDelegate
extension BookSessionViewController: UITableViewDelegate {
    
}

//MARK: - UITableViewDataSource
extension BookSessionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SessionListTableViewCell
        return cell
    }
    
}
