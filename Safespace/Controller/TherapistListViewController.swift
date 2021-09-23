//
//  TherapistListViewController.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 26.08.21.
//

import UIKit

class TherapistListViewController: HasSpinnerViewController {

    @IBOutlet var listLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var selectedIndex = 0
    var loggedInUser: UserData?
    var therapistManager = TherapistManager()
    
    var therapists: [TherapistResponse]? = [TherapistResponse]()
    
    
    let cellIdentifier = "TherapistListTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        therapistManager.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TherapistListTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        tableView.backgroundColor = .white
        tableView.rowHeight = 150.0
        listLabel.text = "Finding Therapists That Match Your Profile..."
        doSpinner()
        therapistManager.getTherapistsForUser(userId: loggedInUser!.id)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as? TherapistProfileViewController
        viewController?.therapist = therapists![selectedIndex]
    }
    
    
}

//MARK: - UITableViewDelegate

extension TherapistListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        doSegue()
    }
}

//MARK: - UITableViewDataSource
extension TherapistListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return therapists!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TherapistListTableViewCell
        let theTherapist = therapists![indexPath.row]
        cell.nameLabel?.text = theTherapist.name as String
        let price = theTherapist.therapistSetting.pricePerSession
        let time = theTherapist.therapistSetting.timePerSession
        cell.priceLabel?.text = "$\(price) / \(time)minutes"
        cell.qualificationLabel.text = theTherapist.therapistSetting.qualifications
        let description = theTherapist.therapistSetting.summary
        
        let index = description.index(description.startIndex, offsetBy: 100)
        cell.descLabel.text = String(description[description.startIndex...index])
        cell.tImageView?.load(url: URL(string: theTherapist.therapistSetting.imageUrl)!)
        cell.seeMoreButton.tag = indexPath.row
        cell.delegate = self
        return cell
    }
    
}

//MARK: - TherapistListTableCellViewDelegate
extension TherapistListViewController: TherapistListTableCellViewDelegate {
    func doSegue() {
        performSegue(withIdentifier: AppConstant.segueToTherapistProfile, sender: self)
    }
    
    func seeMoreButtonTapped(_ button: UIButton) {
        selectedIndex = button.tag
        doSegue()
    }
}

//MARK: - TherapistManager Delegate
extension TherapistListViewController: TherapistManagerDelegate {
    func didGetList(_ tManager: TherapistManager, therapists: [TherapistResponse]) {
        self.therapists = therapists
        DispatchQueue.main.async {
            self.removeSpinner()
            self.tableView.reloadData()
            self.listLabel.text = "\(therapists.count) Therapists Match Your Profile"
        }
    }
    
    func didFailWithError(error: Error) {
        Logger.doLog("Login Error: \(String(describing: error))")
    }
    
    
}
