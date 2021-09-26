//
//  HasSpinnerViewController.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 23.09.21.
//

import UIKit

class HasSpinnerViewController: UIViewController, HasSpinnerView {
    var spinnerVc: SpinnerViewController?
    
    func doSpinner( text:String = "Loading...") {
        spinnerVc = SpinnerViewController(text: text)
        addChild(spinnerVc!)
        spinnerVc!.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(spinnerVc!.view)
        spinnerVc!.didMove(toParent: self)
    }
    
    
    @objc func removeSpinner() {
        DispatchQueue.main.async {
            self.spinnerVc?.willMove(toParent: nil)
            self.spinnerVc?.view.removeFromSuperview()
            self.spinnerVc?.removeFromParent()
        }
    }
    
}
