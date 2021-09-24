//
//  Logger.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 18.09.21.
//

import Foundation


class Logger {
    static func doLog(_ log: String) {
        print("SSLOG: \(log)")
    }
    
    static func doLog(_ data: Any) {
        self.doLog(String(describing: data))
    }
}
