//
//  BookSessionViewController.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 13.09.21.
//

import UIKit

class BookSessionViewController: HasSpinnerViewController {

    @IBOutlet var priceTimeLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var textView: UITextView!
    @IBOutlet var totalPriceLabel: UILabel!
    @IBOutlet var numberOfSessionsLabel: UILabel!
    @IBOutlet var datePicker: UIDatePicker!
    
    var therapist: TherapistResponse?
    var availabilityManager = AvailabilityManager()
    
    var numberOfSessions = 0
    var totalPrice = 0
    
    var sessions = [Time]()
    
    let cellIdentifier = "SessionListTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        availabilityManager.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SessionListTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.backgroundColor = .white
        textView.text = """
            Select a time in \(therapist!.name)'s calendar.
        Since this is your first time you may select a maximum of 2 times
        """
        nameLabel.text = therapist?.name
        priceTimeLabel.text = "$\(therapist!.therapistSetting.pricePerSession) / \(therapist!.therapistSetting.timePerSession) Minutes"
        totalPriceLabel.text = "TOTAL PRICE: $\(totalPrice)"
        numberOfSessionsLabel.text = "SESSIONS: $\(numberOfSessions)"
        datePicker.addTarget(self, action: #selector(selectedDate), for: .valueChanged)
        fetchAvailabilities(getFormattedDate(nil))
    }
    
    @objc func selectedDate(sender: UIDatePicker) {
        let day = sender.date
        let formattedDay = getFormattedDate(day)
        fetchAvailabilities(formattedDay)
    }
    
    func getFormattedDate(_ _date: Date?) -> String {
        var today: Date
        if _date == nil {
            today = Date()
        } else {
            today = _date!
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter.string(from: today)
    }
    
    func fetchAvailabilities(_ day: String) {
        doSpinner()
        availabilityManager.getAvailabilitiesForUser(userId: therapist!.id, day: day)
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
        let time = sessions[indexPath.row]
        cell.timeLabel.text = "\(time.start) - \(time.end)"
        return cell
    }
    
}


extension BookSessionViewController: AvailabilityManagerDelegate {
    func didGetAvailabilities(_ aManager: AvailabilityManager, avails: [Availability]) {
        DispatchQueue.main.async {
            // formatAvailabilities
            for avail in avails {
                for t in avail.times {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
                    let formattedStart = dateFormatter.date(from: t.start)
                    let formattedEnd = dateFormatter.date(from: t.end)
                    dateFormatter.dateFormat = "HH:mm"
                    let time = Time(start: dateFormatter.string(from: formattedStart!), end: dateFormatter.string(from: formattedEnd!))
                    self.sessions.append(time)
                }
            }
            
            self.tableView.reloadData()
        }
        
        removeSpinner()
    }
    
    func didFailWithError(error: Error) {
        Logger.doLog("Availability Error:")
        Logger.doLog(error)
        removeSpinner()
    }
    
}
