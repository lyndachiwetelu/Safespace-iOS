//
//  TherapistProfileViewController.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 12.09.21.
//

import UIKit

class TherapistProfileViewController: UIViewController {

    @IBOutlet var descriptionTextView: UITextView!
    
    @IBOutlet var ailmentsTextView: UITextView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    var therapist: TherapistResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView.text = "Some description about the therapist which just explains more about the kind of illnesses thhey are familiar with handling with different type of illnesses."
        ailmentsTextView.text = "Depression Anxiety PTSD Addictions"
        nameLabel.text = "\(therapist!.name) \(therapist!.therapistSetting.qualifications)"
        imageView.load(url: URL(string: therapist!.therapistSetting.imageUrl)!)
    }

}
