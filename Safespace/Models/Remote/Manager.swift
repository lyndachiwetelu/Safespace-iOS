//
//  Manager.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 24.09.21.
//

import Foundation

protocol Manager {
    func getUserDefault(key:String) -> String
}

extension Manager {
    func getUserDefault(key: String) -> String {
        return UserDefaults.standard.value(forKey: key) as! String
    }
}


