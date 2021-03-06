//
//  SessionMessageCell.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 15.09.21.
//

import UIKit

class SessionMessageCell: UITableViewCell {
 
    @IBOutlet var chatTextView: UITextView!
    @IBOutlet var chatBox: UIView!
    @IBOutlet var leadingConstraint: NSLayoutConstraint!
    @IBOutlet var trailingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        chatBox.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
