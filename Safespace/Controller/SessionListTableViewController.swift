//
//  SessionListTableViewController.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 14.09.21.
//

import UIKit

class SessionListTableViewController: UITableViewController {
    
    var sessions = [
        "active": [
            Session(from: "11:00", to: "12:00", day: "13/04/2021", with: "Maya Agida"),
            Session(from: "12:00", to: "13:00", day: "13/04/2021", with: "Tom Haruna"),
            Session(from: "13:00", to: "14:00", day: "13/04/2021", with: "Becky Geruld"),
        ],
        "upcoming": [
            Session(from: "11:00", to: "12:00", day: "13/04/2021", with: "Mary Agida"),
            Session(from: "12:00", to: "13:00", day: "13/04/2021", with: "Joe Jonas Haruna"),
            Session(from: "13:00", to: "14:00", day: "13/04/2021", with: "Becky Geruld"),
        ],
        "past": [
            Session(from: "11:00", to: "12:00", day: "13/04/2021", with: "Prisma John"),
            Session(from: "12:00", to: "13:00", day: "13/04/2021", with: "Kathleen Ayo"),
        ],
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.sectionHeaderHeight = 50
        tableView.backgroundColor = .white
        tableView.register(SessionListHeader.self,
              forHeaderFooterViewReuseIdentifier: "SessionListSectionHeader")
        tableView.register(UINib(nibName: "SessionListCell", bundle: nil), forCellReuseIdentifier: "SessionListCell")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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

        let typeOfSession = getSectionKey(section: indexPath.section)
        
        switch typeOfSession {
        case "active":
            cell.cancelButton.isHidden = true
        case "past":
            cell.joinButton.isHidden = true
            cell.joinButton.isEnabled = false
            cell.cancelButton.isHidden = true
            cell.detailsButton.isHidden = false
        default:
            cell.joinButton.isHidden = false
            cell.cancelButton.isHidden = false
            cell.detailsButton.isHidden = true
        }
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
