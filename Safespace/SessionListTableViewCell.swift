//
//  SessionListTableViewCell.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 13.09.21.
//

import UIKit

class SessionListTableViewCell: UITableViewCell {
    
    @IBOutlet var selectButton: UIButton!
    @IBOutlet var labelUIView: UIView!
    @IBOutlet var timeLabel: UILabel!
    var sessionIndex: Int?
    var delegate: SessionListTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        labelUIView.layer.borderWidth = 3
        labelUIView.layer.cornerRadius = 10
        labelUIView.layer.borderColor = AppPrimaryColor.color.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func selectButtonPressed(_ sender: UIButton) {
        if sender.title(for: .normal) == "Select" {
            sender.setTitle("Remove", for: .normal)
            sender.backgroundColor = .red
            self.delegate?.didSelectSession(self, sessionIndex: sessionIndex!)
        } else {
            sender.setTitle("Select", for: .normal)
            sender.backgroundColor = AppPrimaryColor.color
            self.delegate?.didDeselectSession(self, sessionIndex: sessionIndex!)
        }
    }
    
    func clearStyling() {
        selectButton.setTitle("Select", for: .normal)
        selectButton.backgroundColor = AppPrimaryColor.color
    }
}

protocol SessionListTableViewCellDelegate {
    func didSelectSession(_ sessionCell: SessionListTableViewCell, sessionIndex: Int)
    func didDeselectSession(_ sessionCell: SessionListTableViewCell, sessionIndex: Int)
}
