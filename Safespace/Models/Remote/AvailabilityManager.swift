//
//  AvailabilityManager.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 23.09.21.
//

import Foundation

struct AvailabilityManager: UsesUserDefaults {
    
    let baseURL = "https://safespace-graphql.lyndachiwetelu.com/graphql"
    var delegate: AvailabilityManagerDelegate?
    
    func getAvailabilitiesForUser(userId: Int, day:String) {
        performRequest(userId: userId, day: day)
    }
    
    func performRequest(userId: Int, day: String) {
        if let url = URL(string: baseURL) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            let accessToken = getUserDefault(key: AppConstant.apiToken)
            request.setValue(accessToken, forHTTPHeaderField: "access-token")
            
            let requestBodyDict = [
                "query": """
                    query availabilities {
                         getAvailabilitiesForUserByDay(userId: "\(userId)", day: "\(day)") {
                            id
                            day
                            userId
                            times {
                               start
                               end
                            }
                              
                        }
                    }
                """
            ]
            
            guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBodyDict, options: []) else {
                return
            }
            request.httpBody = httpBody
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: request) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                }
                
                if let safeData = data {
                    if let availabilities = self.parseJSON(availabilities: safeData) {
                        self.delegate?.didGetAvailabilities(self, avails: availabilities)
                    }
                }
                
            }
            
            task.resume()
            
        }
    }
    
    func parseJSON(availabilities: Data) -> [Availability]? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(AvailabilityListResponse.self, from: availabilities)
            return decodedData.data.getAvailabilitiesForUserByDay
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}

protocol AvailabilityManagerDelegate {
    func didGetAvailabilities(_ aManager: AvailabilityManager, avails: [Availability])
    func didFailWithError(error: Error)
}


