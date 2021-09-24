//
//  PLoginViewController.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 24.08.21.
//

import UIKit

class LoginViewController: HasSpinnerViewController, UsesUserDefaults {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var submitButton: UIButton!
    var networkBusy: Bool = false
    var loggedInUser: LoginUserResponse?
    
    private var network = LoginManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        network.delegate = self
    }
    
    @IBAction func submitPressed(_ sender: UIButton) {
        emailTextField.endEditing(true)
        passwordTextField.endEditing(true)
        networkBusy = true
        doSpinner()
        network.loginUser(email: emailTextField.text!, password: passwordTextField.text!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AppConstant.segueToMainTab {
            let dest = segue.destination as? UITabBarController
            let vc = dest?.viewControllers?.first as? TherapistListViewController
            vc?.loggedInUser = loggedInUser?.user
        }
    }
    
}

extension LoginViewController: LoginManagerDelegate {
    func didLogin(_ networkManager: LoginManager, user: LoginUserResponse) {
        networkBusy = false
        loggedInUser = user
        DispatchQueue.main.async {
            self.setUserDefault(value: user.token, forKey: AppConstant.apiToken)
            self.setUserDefault(value: String(user.user.id), forKey: AppConstant.userId)
            self.removeSpinner()
            self.performSegue(withIdentifier: AppConstant.segueToMainTab, sender: self)
        }
    }
    
    func didFailWithError(error: Error) {
        networkBusy = false
        Logger.doLog("Login Error: \(String(describing: error))")
        self.removeSpinner()
    }
    
}
