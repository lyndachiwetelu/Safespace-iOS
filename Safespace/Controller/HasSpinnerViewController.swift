//
//  HasSpinnerViewController.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 23.09.21.
//

import UIKit

class HasSpinnerViewController: UIViewController, HasSpinnerView {
    var spinnerVc: SpinnerViewController?
    
    func doSpinner() {
        spinnerVc = SpinnerViewController()
        addChild(spinnerVc!)
        spinnerVc!.view.frame = view.frame
        view.addSubview(spinnerVc!.view)
        NSLayoutConstraint.activate([
            spinnerVc!.view.topAnchor.constraint(equalTo:  view.layoutMarginsGuide.topAnchor)
        ])
        spinnerVc!.didMove(toParent: self)
    }
    
    
    func removeSpinner() {
        spinnerVc?.willMove(toParent: nil)
        spinnerVc?.view.removeFromSuperview()
        spinnerVc?.removeFromParent()
    }
    
}
