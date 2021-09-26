//
//  SessionListCell.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 14.09.21.
//

import UIKit

class SessionListCell: UITableViewCell {
    
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    var typeOfSession: String?
    var delegate: SessionListCellDelegate?
    var index: Int?

    @IBOutlet var joinButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var detailsButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func detailsPressed(_ sender: UIButton) {
        self.delegate?.detailsPressed(sender, index: index!, sessionType: typeOfSession!)
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
    }
    
    func setButtonsToDefaultState() {
        joinButton.isEnabled = true
        cancelButton.isEnabled  = true
        detailsButton.isEnabled  = true
        
        joinButton.isHidden = true
        cancelButton.isHidden = true
        detailsButton.isHidden = true
        
        joinButton.alpha = 1
        cancelButton.alpha = 1
        detailsButton.alpha = 1
    }
    
    @IBAction func joinPressed(_ sender: UIButton) {
        self.delegate?.joinPressed(sender, index: index!, sessionType: typeOfSession!)
    }
}


protocol SessionListCellDelegate {
    func joinPressed(_ sender: UIButton, index: Int, sessionType: String)
    func detailsPressed(_ sender: UIButton, index: Int, sessionType: String)
}
