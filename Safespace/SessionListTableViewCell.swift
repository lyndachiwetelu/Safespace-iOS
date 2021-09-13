//
//  SessionListTableViewCell.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 13.09.21.
//

import UIKit

class SessionListTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func selectButtonPressed(_ sender: UIButton) {
        sender.setTitle("Selected", for: .normal)
    }
}
