//
//  TherapistProfileViewController.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 12.09.21.
//

import UIKit

class TherapistProfileViewController: UIViewController {

    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var priceTimeLabel: UILabel!
    @IBOutlet var chatIconView: UIImageView!
    @IBOutlet var videoIconView: UIImageView!
    @IBOutlet var audioIconView: UIImageView!
    @IBOutlet var specializeLabel: UILabel!
    @IBOutlet var ailmentsTextView: UITextView!
    
    @IBOutlet var summaryTextView: UITextView!
    var therapist: TherapistResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatIconView.isHidden = true
        videoIconView.isHidden = true
        audioIconView.isHidden = true
        descriptionTextView.text = therapist!.therapistSetting.summary
        specializeLabel.text = "\(therapist!.name) specializes in:"
        ailmentsTextView.text = getAilmentsText(ailments: therapist!.ailments)
        nameLabel.text = "\(therapist!.name) \(therapist!.therapistSetting.qualifications)"
        imageView.load(url: URL(string: therapist!.therapistSetting.imageUrl)!)
        priceTimeLabel.text = """
$\(therapist!.therapistSetting.pricePerSession) / \(therapist!.therapistSetting.timePerSession) minutes
"""
        showHideMedia(media: therapist!.media)
    }
    
    func getAilmentsText(ailments: [Ailment]) -> String {
        let _ailments = ailments.map { ailment in
            ailment.name
        }
        
        return _ailments.joined(separator: "\n")
    }
    
    func showHideMedia(media: [Media]) {
        let keys = media.map { media in
            media.mediaKey
        }
        
        if keys.contains(MediaKey.text.rawValue) {
            chatIconView.isHidden = false
        }
        
        if keys.contains(MediaKey.video.rawValue) {
            videoIconView.isHidden = false
        }
        
        if keys.contains(MediaKey.voice.rawValue) {
            audioIconView.isHidden = false
        }
        
    }

}
