//
//  SessionListCell.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 14.09.21.
//

import UIKit

class SessionListCell: UITableViewCell {
    
    var typeOfSession: String?

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
    
}
