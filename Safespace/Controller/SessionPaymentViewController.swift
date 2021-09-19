//
//  SessionPaymentViewController.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 14.09.21.
//

import UIKit

class SessionPaymentViewController: UIViewController {

    @IBOutlet var paypalCheckBox: UIView!
    @IBOutlet var creditCardCheckBox: UIView!
    @IBOutlet var creditCardLabel: UILabel!
    @IBOutlet var paypalLabel: UILabel!
    
    private let ccTag = 100
    private let ppTag = 200
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyCheckboxStyle()
        addTapRecognizers()
    }
    
    func addTapRecognizers() {
        let ccTap = UITapGestureRecognizer(target: self, action: #selector(self.ccTapped))
        creditCardCheckBox.addGestureRecognizer(ccTap)
        let ppTap = UITapGestureRecognizer(target: self, action: #selector(self.ppTapped))
        paypalCheckBox.addGestureRecognizer(ppTap)
        
    }
    
    @objc func ccTapped(gesture: UITapGestureRecognizer) {
        fillCheckBox(gesture)
    }
    
    @objc func ppTapped(gesture: UITapGestureRecognizer) {
        fillCheckBox(gesture)
    }
    
    func fillCheckBox(_ gesture: UITapGestureRecognizer) {
        switch gesture.view?.tag {
        case ppTag:
            creditCardCheckBox.backgroundColor = .white
            creditCardLabel.textColor = .black
            paypalLabel.textColor = AppPrimaryColor.color
        default:
            paypalCheckBox.backgroundColor = .white
            paypalLabel.textColor = .black
            creditCardLabel.textColor = AppPrimaryColor.color
        }
        gesture.view?.backgroundColor = AppPrimaryColor.color
    }
    
    func applyCheckboxStyle() {
        paypalCheckBox.layer.borderWidth = 5
        paypalCheckBox.layer.borderColor = AppPrimaryColor.color.cgColor
        paypalCheckBox.backgroundColor = .white
        paypalCheckBox.tag = ppTag
        
        creditCardCheckBox.backgroundColor = .white
        creditCardCheckBox.layer.borderWidth = 5
        creditCardCheckBox.layer.borderColor = AppPrimaryColor.color.cgColor
        creditCardCheckBox.tag = ccTag
    }

}
