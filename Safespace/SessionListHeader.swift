//
//  SessionListTableViewHeaderFooterView.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 14.09.21.
//

import UIKit

class SessionListHeader: UITableViewHeaderFooterView {
        let title = UILabel()
        let container = UIView()

        override init(reuseIdentifier: String?) {
            super.init(reuseIdentifier: reuseIdentifier)
            configureViews()
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
        func configureViews() {
            container.translatesAutoresizingMaskIntoConstraints = false
            title.translatesAutoresizingMaskIntoConstraints = false
    
            container.backgroundColor = .white
            container.layer.borderWidth = 2
            container.layer.borderColor = AppPrimaryColor.color.cgColor
            title.textColor = AppPrimaryColor.color

            container.addSubview(title)
            contentView.addSubview(container)
            contentView.backgroundColor = .white
            
      
            NSLayoutConstraint.activate([
                container.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 50),
                container.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
                container.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
                container.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor,  constant: -50),

                title.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                title.centerXAnchor.constraint(equalTo: container.centerXAnchor),


                container.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                container.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                
            ])
        }


}
