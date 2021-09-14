//
//  SessionDetailViewController.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 14.09.21.
//

import UIKit

class SessionDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = getRightBarView()
        navigationItem.titleView = getTitleView()
        
    }
    
    func getRightBarView() -> UIBarButtonItem {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fillEqually
        view.spacing = 30
  
        let video = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        video.image = UIImage(systemName: "camera.fill")
        
        let audio = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        audio.image = UIImage(systemName: "phone.fill")
        
        
        view.frame =  CGRect(x: 0, y: 0, width: 150, height: 50)
        view.addArrangedSubview(video)
        view.addArrangedSubview(audio)
        
        return UIBarButtonItem(customView: view)
    }
    
    func getTitleView() -> UIStackView {
        let view = UIStackView(frame: CGRect(x: 0, y: 0, width: 20, height: 80))
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fillEqually
        view.spacing = 10
  
        let avatar = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        avatar.image = UIImage(named: "avi1")
        avatar.layer.cornerRadius = avatar.frame.size.width / 2
        avatar.clipsToBounds = true
        
        let label = UILabel()
        label.text = "Mary Agida"
        
    
        view.backgroundColor = .red
        view.addArrangedSubview(avatar)
        view.addArrangedSubview(label)
        view.clipsToBounds = true
        
        return view
    }


}
