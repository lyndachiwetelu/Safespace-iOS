//
//  PQuestionnaireViewController.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 24.08.21.
//

import UIKit

class QuestionnaireViewController: UIViewController {
    @IBOutlet var ailmentPickerViewer: UIPickerView!
    @IBOutlet var religiousTherapistPicker: UIPickerView!
    @IBOutlet var mediaPicker: UIPickerView!
    @IBOutlet var ageTextField: UITextField!
    @IBOutlet var stepper: UIStepper!
    @IBOutlet var beenInTherapySwitch: UISwitch!
    @IBOutlet var couplesTherapySwitch: UISwitch!
    
    var selectedAilmentIndex: Int = 0
    var selectedReligionIndex: Int = 0
    var selectedMediaIndex: Int = 0
    
    let ailments = AppConstant.ailments
    let religions = AppConstant.religions
    
    var questionnaire: Questionnaire?
    
    let media = ["voice", "video", "text", "all"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGestureRecognizer()
        beenInTherapySwitch.setOn(false, animated: false)
        couplesTherapySwitch.setOn(false, animated: false)
        religiousTherapistPicker.dataSource = self
        religiousTherapistPicker.delegate = self
        ailmentPickerViewer.dataSource = self
        ailmentPickerViewer.delegate = self
        mediaPicker.dataSource = self
        mediaPicker.delegate = self
    }
    
    func addGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(endTextFieldEditing))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func endTextFieldEditing() {
        ageTextField.endEditing(true)
    }
    
    @IBAction func continueButtonPressed(_ sender: UIButton) {
        let age = Int(ageTextField.text!)
        let beenInTherapy = beenInTherapySwitch.isOn
        let ailments = [ailments[selectedAilmentIndex]["name"]!]
        let media =  [media[selectedMediaIndex]]
        let couplesTherapy = couplesTherapySwitch.isOn
        let religiousTherapy = religions[selectedReligionIndex]
       
        questionnaire = Questionnaire(age: age!, hasHadTherapy: beenInTherapy, ailments: ailments, media: media, religiousTherapy: religiousTherapy, couplesTherapy: couplesTherapy)
        performSegue(withIdentifier: AppConstant.segueToSignUpScreen, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AppConstant.segueToSignUpScreen {
            let viewController = segue.destination as! SignupViewController
            viewController.questionnaire = questionnaire
        }
    }
    
}

extension QuestionnaireViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 100:
            return ailments.count
        case 200:
            return religions.count
        default:
            return media.count
        }
    }
    
}

extension QuestionnaireViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 100:
            selectedAilmentIndex = row
        case 200:
            selectedReligionIndex = row
        default:
            selectedMediaIndex = row
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        var str: String?
        
        switch pickerView.tag {
        case 100:
            str = ailments[row]["name"]
        case 200:
            str = religions[row]
        default:
            str = media[row].capitalized
            
        }
        
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = UIColor.black

        let attributedString = NSAttributedString(string: str!, attributes: attributes)
        
        return attributedString
    }
}
