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
    
    var numberOfSessions = 0 {
        didSet {
            numberOfSessionsLabel.text = "SESSIONS: \(numberOfSessions)"
        }
    }
    
    var totalPrice = 0  {
        didSet {
            totalPriceLabel.text = "TOTAL PRICE: $\(totalPrice)"
        }
    }
    
    var sessions = [DayTime]()
    
    var selectedSessions: [DayTime] = [DayTime]() {
        didSet {
            totalPrice = (therapist?.therapistSetting.pricePerSession)! * selectedSessions.count
            numberOfSessions = selectedSessions.count
        }
    }
    
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
        numberOfSessionsLabel.text = "SESSIONS: \(numberOfSessions)"
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AppConstant.segueToPayForSession {
            let dest = segue.destination as! SessionPaymentViewController
            dest.sessions = selectedSessions
            dest.therapist = therapist
        }
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
        cell.clearStyling()
        let dayTime = sessions[indexPath.row]
        cell.sessionIndex = indexPath.row
        cell.delegate = self
        cell.timeLabel.text = "\(dayTime.time.start) - \(dayTime.time.end)"
        return cell
    }
    
}


extension BookSessionViewController: AvailabilityManagerDelegate {
    func didGetAvailabilities(_ aManager: AvailabilityManager, avails: [Availability]) {
        DispatchQueue.main.async {
            // formatAvailabilities
            var _avails = [DayTime]()
            for avail in avails {
                for t in avail.times {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
                    let formattedStart = dateFormatter.date(from: t.start)
                    let formattedEnd = dateFormatter.date(from: t.end)
                    dateFormatter.dateFormat = "HH:mm"
                    let time = Time(start: dateFormatter.string(from: formattedStart!), end: dateFormatter.string(from: formattedEnd!))
                    let dayTime = DayTime(availabilityId: avail.id, day: avail.day, time: time)
                    _avails.append(dayTime)
                }
            }
            self.sessions = _avails
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


extension BookSessionViewController : SessionListTableViewCellDelegate {
    func didSelectSession(_ sessionCell: SessionListTableViewCell, sessionIndex: Int) {
        selectedSessions.append(sessions[sessionIndex])
    }
    
    func didDeselectSession(_ sessionCell: SessionListTableViewCell, sessionIndex: Int) {
        selectedSessions = selectedSessions.filter { dayTime in
            (dayTime.time == sessions[sessionIndex].time) == false
        }
    }
}
