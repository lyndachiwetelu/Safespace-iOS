//
//  TherapistListTableViewCell.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 26.08.21.
//

import UIKit

class TherapistListTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var qualificationLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descLabel: UITextView!

    @IBOutlet var tImageView: UIImageView!
    
    var delegate: TherapistListTableCellViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func seeMorePressed(_ sender: UIButton) {
        delegate?.doSegue()
    }
}


protocol TherapistListTableCellViewDelegate {
    func doSegue()
}
