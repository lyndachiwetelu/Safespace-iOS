//
//  PaymentSuccessViewController.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 14.09.21.
//

import UIKit

class PaymentSuccessViewController: UIViewController {
    
    @IBOutlet var paymentSuccessLabel: UILabel!
    var numberOfSessions = 0
    var therapist: TherapistResponse?

    override func viewDidLoad() {
        super.viewDidLoad()
        paymentSuccessLabel.text = "Your Payment for \(numberOfSessions) Sessions with \(therapist?.name ?? "") was Successful!"
    }

}
