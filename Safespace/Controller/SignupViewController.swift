//
//  PSignupViewController.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 25.08.21.
//

import UIKit

class SignupViewController: UIViewController, UsesUserDefaults {
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmPasswordTextField: UITextField!
    
    var questionnaire: Questionnaire?
    var signupManager = SignupManager()
    var signedInUser: UserData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGestureRecognizer()
        signupManager.delegate = self
    }
    
    func addGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(endTextFieldEditing))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func endTextFieldEditing() {
        nameTextField.endEditing(true)
        emailTextField.endEditing(true)
        passwordTextField.endEditing(true)
        confirmPasswordTextField.endEditing(true)
        
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        let name = nameTextField.text!
        let password = passwordTextField.text!
        let email = emailTextField.text!
        let signupData = SignupRequest(name: name, email: email, password: password, settings: questionnaire!)
        signupManager.signupUser(signupData: signupData)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AppConstant.segueToMainTab {
            let dest = segue.destination as? UITabBarController
            let vc = dest?.viewControllers?.first as? TherapistListViewController
            vc?.loggedInUser = signedInUser
        }
    }
    
}

extension SignupViewController: SignupManagerDelegate {
    func didSignup(_ SignupManager: SignupManager, user: SignupUserResponse) {
        Logger.doLog(String(describing: user))
        DispatchQueue.main.async {
            self.signedInUser = UserData(id: user.user.id, name: user.user.name, userType: user.user.userType)
            self.setUserDefault(value: user.token, forKey: AppConstant.apiToken)
            self.setUserDefault(value: String(user.user.id), forKey: AppConstant.userId)
            self.performSegue(withIdentifier: AppConstant.segueToMainTab, sender: self)
        }
    }
    
    func didFailWithError(error: Error) {
        Logger.doLog("Signup Error \(String(describing: error))")
    }
    
}
