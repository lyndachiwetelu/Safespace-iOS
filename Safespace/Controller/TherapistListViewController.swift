//
//  TherapistListViewController.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 26.08.21.
//

import UIKit

class TherapistListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    let therapists = [
        
        ["Jamil", #imageLiteral(resourceName: "av4")],
        ["Jemila", #imageLiteral(resourceName: "avi1")],
        ["Kunle", #imageLiteral(resourceName: "avi2")],
        ["Aberdeen", #imageLiteral(resourceName: "av3")],
        ["Salusi", #imageLiteral(resourceName: "av4")]
    ];
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TherapistListTableViewCell", bundle: nil), forCellReuseIdentifier: "TherapistListTableViewCell")
        tableView.backgroundColor = .white
        tableView.rowHeight = 150.0

        // Do any additional setup after loading the view.
    }
    
}

extension TherapistListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
    
}



extension TherapistListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return therapists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TherapistListTableViewCell", for: indexPath) as! TherapistListTableViewCell
        cell.nameLabel?.text = therapists[indexPath.row][0] as? String
        cell.priceLabel?.text = "$80 / 30minutes"
        cell.qualificationLabel.text = "B.Sc"
        let description = "Some description about the therapist which we need to continue this app Like wtf! Some description about the therapist which we need to continue this app Like wtf!"
        
        let index = description.index(description.startIndex, offsetBy: 100)
        cell.descLabel.text = String(description[description.startIndex...index])
        cell.tImageView?.image = therapists[indexPath.row][1] as? UIImage
        cell.delegate = self
        return cell
    }
    
}


extension TherapistListViewController: TherapistListTableCellViewDelegate {
    func doSegue() {
        performSegue(withIdentifier: "goToTherapistProfile", sender: nil)
    }
}
