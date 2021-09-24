//
//  UsesUserDefaults.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 24.09.21.
//

import Foundation

protocol UsesUserDefaults {
    func getUserDefault(key:String) -> String
    func setUserDefault(value: String, forKey: String)
}

extension UsesUserDefaults {
    func getUserDefault(key: String) -> String {
        return UserDefaults.standard.value(forKey: key) as! String
    }
    
    func setUserDefault(value: String, forKey: String) {
        UserDefaults.standard.set(value, forKey: forKey)
    }
}
