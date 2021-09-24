//
//  SessionPaymentViewController.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 14.09.21.
//

import UIKit

class SessionPaymentViewController: HasSpinnerViewController {

    @IBOutlet var selectionLabel: UILabel!
    @IBOutlet var sessionsStackView: UIStackView!
    @IBOutlet var paypalCheckBox: UIView!
    @IBOutlet var creditCardCheckBox: UIView!
    @IBOutlet var creditCardLabel: UILabel!
    @IBOutlet var paypalLabel: UILabel!
    
    var sessions = [DayTime]()
    var therapist: TherapistResponse?
    var selectedPayment: String?
    
    var sessionManager = SessionManager()
    
    private let ccTag = 100
    private let ppTag = 200
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sessionManager.delegate = self
        applyCheckboxStyle()
        addTapRecognizers()
        addSessionsLabels()
        selectionLabel.text = "YOU HAVE SELECTED \(sessions.count) SESSIONS WITH \(therapist?.name ?? "")"
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
    
    func addSessionsLabels() {
        for session in sessions {
            let timeLabel = UILabel()
            timeLabel.textAlignment = .center
            timeLabel.text = "\(session.time.start) - \(session.time.end)"
            timeLabel.textColor = .black
            let dayLabel = UILabel()
            dayLabel.text = session.day
            dayLabel.textAlignment = .center
            dayLabel.textColor = .black
            let stack = UIStackView()
            stack.distribution = .fillEqually
            stack.axis = .horizontal
            stack.addArrangedSubview(timeLabel)
            stack.addArrangedSubview(dayLabel)
            sessionsStackView.addArrangedSubview(stack)
        }
    }
    
    func fillCheckBox(_ gesture: UITapGestureRecognizer) {
        switch gesture.view?.tag {
        case ppTag:
            selectedPayment = AppConstant.payPal
            creditCardCheckBox.backgroundColor = .white
            creditCardLabel.textColor = .black
            paypalLabel.textColor = AppPrimaryColor.color
        default:
            selectedPayment = AppConstant.creditCard
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

    @IBAction func payNowPressed(_ sender: UIButton) {
        var requests = [SessionRequest]()
        let userId = getUserDefault(key: AppConstant.userId)
        for session in sessions {
            let request = SessionRequest(availabilityId: session.availabilityId, requestedBy: Int(userId)!, from: session.time.start, to: session.time.end)
            requests.append(request)
        }
        doSpinner()
        sessionManager.createSessions(sessions: requests)
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
    }
    
    func getUserDefault(key: String) -> String {
        return UserDefaults.standard.value(forKey: key) as! String
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AppConstant.segueToPaymentSuccess {
            let dest = segue.destination as! PaymentSuccessViewController
            dest.numberOfSessions = sessions.count
            dest.therapist = therapist
        }
    }
}

extension SessionPaymentViewController: SessionManagerDelegate {
    func didEndCreation(_ sManager: SessionManager, ended: Bool) {
        removeSpinner()
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: AppConstant.segueToPaymentSuccess, sender: self)
        }
    }
    
    func didCreateSession(_ sManager: SessionManager, session: SessionResponse) {
    }
    
    func didFailWithError(error: Error) {
        removeSpinner()
        Logger.doLog("Session Creation Error:")
        Logger.doLog(error)
    }
    
    
}
