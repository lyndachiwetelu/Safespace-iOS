//
//  SignupManager.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 23.09.21.
//

import Foundation

struct SignupManager {
    
    let baseURL = "https://safespace-graphql.lyndachiwetelu.com/graphql"
    var delegate: SignupManagerDelegate?
    
    func signupUser(signupData: SignupRequest) {
        performRequest(signupData)
    }
    
    func performRequest(_ signupData: SignupRequest) {
        if let url = URL(string: baseURL) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("true", forHTTPHeaderField: "mobile")
            
            let requestBody = [
                "query": """
                    mutation MyMutation {
                      signupUser(
                        input: {
                    email: "jkab@gmail.com",
                    name: "JK the Slayer",
                    password: "chichi",
                    settings: {
                        age: 30,
                        ailments: ["depression",],
                        couplesTherapy: false,
                        hasHadTherapy: false,
                        media: ["video" "voice"],
                        religiousTherapy: "none"
                    }
                    
                    }
                      ) {
                           user {
                            id
                            name
                            userType
                           }
                           token
                        }
                      }
                    }

                    """
            
            ]
            
            let requestBodyDict = [
                "query": """
                    mutation signup {
                      signupUser( input: {
                            email: "\(signupData.email)",
                            password: "\(signupData.password)",
                            name: "\(signupData.name)",
                            settings: {
                                age: \(signupData.settings.age),
                                hasHadTherapy:  \(signupData.settings.hasHadTherapy),
                                ailments: \(getArrayOfStrings(array: signupData.settings.ailments)),
                                media: \(getArrayOfStrings(array: signupData.settings.media)),
                                religiousTherapy: "\(signupData.settings.religiousTherapy.lowercased())",
                                couplesTherapy: \(signupData.settings.couplesTherapy)
                            }
                
                }) {
                       user {
                           id name userType
                       }
                       token
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
                    Logger.doLog(String(decoding: safeData, as: UTF8.self))
                    if let user = self.parseJSON(userData: safeData) {
                        self.delegate?.didSignup(self, user: user)
                    }
                }
                
            }
            
            task.resume()
            
        }
    }
    
    func parseJSON(userData: Data) -> SignupUserResponse? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(SignupResponse.self, from: userData)
            return decodedData.data.signupUser
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func getArrayOfStrings(array: [String]) -> String {
        var str = "["
        for item in array {
            str.append("\"\(item.lowercased())\" ")
        }
        str.append("]")
        return str
    }
    
}

protocol SignupManagerDelegate {
    func didSignup(_ SignupManager: SignupManager, user: SignupUserResponse)
    
    func didFailWithError(error: Error)
}
