//
//  PQuestionnaireViewController.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 24.08.21.
//

import UIKit

class PQuestionnaireViewController: UIViewController {
    @IBOutlet var ailmentPickerViewer: UIPickerView!
    @IBOutlet var religiousTherapistPicker: UIPickerView!
    @IBOutlet var mediaPicker: UIPickerView!
    
    let ailments = [
            [
                "name": "Depression",
                "key": "depression"
            ],
            [
                "name": "Anxiety",
                "key": "anxiety"
            ],
            [
                "name": "Bipolar Disorder",
                "key": "bipolar"
            ],
            [
                "name": "Eating Disorders",
                "key": "eating-disorder"
            ],
            [
                "name": "PTSD",
                "key": "ptsd"
            ],
            [
                "name": "Addictions",
                "key": "addiction"
            ],
            [
                "name": "Personality Disorder",
                "key": "personality-disorder"
            ],
    ]
    
    
    let religions = [
        "None",
        "Christian",
        "Muslim",
        "Hindu",
        "Buddhist"
    ]
    
    let media = ["Voice", "Video", "Text", "All"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        religiousTherapistPicker.dataSource = self
        religiousTherapistPicker.delegate = self
        ailmentPickerViewer.dataSource = self
        ailmentPickerViewer.delegate = self
        mediaPicker.dataSource = self
        mediaPicker.delegate = self
    }
}

extension PQuestionnaireViewController: UIPickerViewDataSource {
    
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

extension PQuestionnaireViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        var str: String?
        
        switch pickerView.tag {
        case 100:
            str = ailments[row]["name"]
        case 200:
            str = religions[row]
        default:
            str = media[row]
            
        }
        
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = UIColor.black

        let attributedString = NSAttributedString(string: str!, attributes: attributes)
        
        return attributedString
    }
}
