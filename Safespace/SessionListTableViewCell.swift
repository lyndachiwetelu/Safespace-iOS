//
//  SessionListTableViewCell.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 13.09.21.
//

import UIKit

class SessionListTableViewCell: UITableViewCell {
    
    @IBOutlet var labelUIView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        labelUIView.layer.borderWidth = 3
        labelUIView.layer.cornerRadius = 10
        labelUIView.layer.borderColor = UIColor(named: "App Teal")?.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func selectButtonPressed(_ sender: UIButton) {
        sender.setTitle("Selected", for: .normal)
    }
}
