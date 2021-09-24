//
//  SessionListTableViewController.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 14.09.21.
//

import UIKit

class SessionListTableViewController: UITableViewController, UsesUserDefaults {
    
    var sessionManager = SessionManager()
    
    var sessions = [
        "active": [UserSession](),
        "upcoming": [UserSession](),
        "past": [UserSession](),
    ]
    
    var readOnlySession: Bool = false
    var selectedIndex: Int?
    var selectedSection: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        sessionManager.fetchDelegate = self
        tableView.sectionHeaderHeight = 50
        tableView.backgroundColor = .white
        tableView.register(SessionListHeader.self,
              forHeaderFooterViewReuseIdentifier: "SessionListSectionHeader")
        tableView.register(UINib(nibName: "SessionListCell", bundle: nil), forCellReuseIdentifier: "SessionListCell")
        fetchSessions()
    }
    
    func getSectionKey(section: Int) -> String {
        var sectionKey: String?
        switch section {
        case 0:
            sectionKey = "active"
        case 1:
            sectionKey = "upcoming"
        default:
            sectionKey = "past"
        }
        
        return sectionKey!
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sessions.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionKey = getSectionKey(section: section)
        return sessions[sectionKey]!.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionKey = getSectionKey(section: section)
        
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier:
                       "SessionListSectionHeader") as! SessionListHeader
        view.title.text = sectionKey.uppercased()
           return view
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionListCell", for: indexPath) as! SessionListCell
        cell.delegate = self

        let typeOfSession = getSectionKey(section: indexPath.section)
        cell.setButtonsToDefaultState()
        
        switch typeOfSession {
            case SessionType.active.rawValue:
                cell.joinButton.isHidden = false
            case SessionType.past.rawValue:
                cell.detailsButton.isHidden = false
            case SessionType.upcoming.rawValue:
                cell.joinButton.isHidden = false
                cell.joinButton.isEnabled = false
                cell.cancelButton.isHidden = false
            default:
                cell.joinButton.isHidden = false
                cell.cancelButton.isHidden = false
        }
        
        let cellData = sessions[typeOfSession]![indexPath.row]
        cell.index = indexPath.row
        cell.nameLabel.text = cellData.with
        cell.timeLabel.text = "\(cellData.from) - \(cellData.to)"
        cell.dayLabel.text = cellData.day
        cell.typeOfSession = typeOfSession
        
        return cell
    }

    func fetchSessions() {
        let userId = getUserDefault(key: AppConstant.userId)
        sessionManager.getUserSessions(userId: Int(userId)!)
    }
    
    func groupAndSetSessions(sessions: [UserSessionResponse]) {
        var active = [UserSession]()
        var upcoming = [UserSession]()
        var past = [UserSession]()
        let userId = Int(getUserDefault(key: AppConstant.userId))!
        
        for session in sessions {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd HH:mm"
            let start = "\(session.day) \(session.from)"
            let end = "\(session.day) \(session.to)"
            let formattedStart = dateFormatter.date(from: start)
            let formattedEnd = dateFormatter.date(from: end)
            
            let theSession = UserSession(id:session.id, from: session.from, to: session.to, day: session.day.replacingOccurrences(of: "-", with: "/"), with: session.therapistInfo.name, imageUrl: session.therapistInfo.therapistSetting.imageUrl, therapistId: session.therapistInfo.id, userId: userId)
            
            let today = Date()
            if today > formattedEnd! {
                past.append(theSession)
            } else if today < formattedStart! {
                upcoming.append(theSession)
            } else if today >= formattedStart! && today <= formattedEnd! {
                active.append(theSession)
            }
        }
        
        self.sessions["active"] = active
        self.sessions["upcoming"] = upcoming
        self.sessions["past"] = past
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AppConstant.segueToSession {
            let dest = segue.destination as! SessionDetailViewController
            dest.userSession = sessions[selectedSection!]![selectedIndex!]
            dest.readOnlySession = readOnlySession
        }
    }

}


extension SessionListTableViewController: SessionListCellDelegate {
    func goToSession() {
        performSegue(withIdentifier: AppConstant.segueToSession, sender: self)
    }
    
    func detailsPressed(_ sender: UIButton, index: Int, sessionType: String) {
        selectedIndex = index
        selectedSection = sessionType
        readOnlySession = true
        goToSession()
    }
    
    func joinPressed(_ sender: UIButton, index: Int, sessionType: String) {
        readOnlySession = false
        selectedIndex = index
        selectedSection = sessionType
        goToSession()
    }
    
}

extension SessionListTableViewController: SessionManagerFetchDelegate {
    func didFetchSessions(_ sManager: SessionManager, sessions: [UserSessionResponse]? = [UserSessionResponse]()) {
        groupAndSetSessions(sessions: sessions!)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func didFailWithError(error: Error) {
        Logger.doLog("Session Fetch Error")
        Logger.doLog(error)
    }
    
}
