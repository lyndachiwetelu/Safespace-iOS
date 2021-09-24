//
//  TherapistManager.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 22.09.21.
//

import Foundation

struct TherapistManager: Manager {
    
    let baseURL = "https://safespace-graphql.lyndachiwetelu.com/graphql"
    var delegate: TherapistManagerDelegate?
    
    func getTherapistsForUser(userId: Int) {
        performRequest(userId: userId)
    }
    
    func performRequest(userId: Int) {
        if let url = URL(string: baseURL) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            let accessToken = getUserDefault(key: AppConstant.apiToken)
            request.setValue(accessToken, forHTTPHeaderField: "access-token")
            
            let requestBodyDict = [
                "query": """
                    query therapists {
                       getTherapists(userId: "\(userId)") {
                            id
                            name
                            userType
                            therapistSetting {
                                ageFrom
                                ageTo
                                qualifications
                                timePerSession
                                religiousTherapy
                                couplesTherapy
                                summary
                                imageUrl
                                pricePerSession
                            }
                            media {
                                id
                                name
                                userId
                                mediaKey
                            }
                            ailments {
                                id
                                name
                                userId
                                ailmentKey
                            }
                    }}
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
                    //                    Logger.doLog(String(decoding: safeData, as: UTF8.self))
                    if let therapists = self.parseJSON(therapistsData: safeData) {
                        self.delegate?.didGetList(self, therapists: therapists)
                    }
                }
                
            }
            
            task.resume()
            
        }
    }
    
    func parseJSON(therapistsData: Data) -> [TherapistResponse]? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(TherapistListResponse.self, from: therapistsData)
            return decodedData.data.getTherapists
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}

protocol TherapistManagerDelegate {
    func didGetList(_ tManager: TherapistManager, therapists: [TherapistResponse])
    
    func didFailWithError(error: Error)
}

