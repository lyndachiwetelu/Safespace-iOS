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

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TherapistListViewController: UITableViewDelegate {
    
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
        cell.descLabel.text = "Some description about the therapist which we need to continue this app Like wtf! Some description about the therapist which we need to continue this app Like wtf!"
        cell.tImageView?.image = therapists[indexPath.row][1] as? UIImage
        return cell
    }
    
}
