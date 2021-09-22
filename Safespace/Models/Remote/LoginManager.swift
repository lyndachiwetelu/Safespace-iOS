//
//  NetworkManager.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 22.09.21.
//

import Foundation

struct LoginManager {
    
    let baseURL = "https://safespace-graphql.lyndachiwetelu.com/graphql"
    var delegate: LoginManagerDelegate?
    
    func loginUser(email: String, password: String) {
        performRequest(email:email, password:password)
    }
    
    func performRequest(email: String, password: String) {
        if let url = URL(string: baseURL) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("true", forHTTPHeaderField: "mobile")
            
            let requestBodyDict = [
                "query": """
                    mutation login {
                      loginUser(input: {email: \"\(email)\", password:\"\(password)\"}) {
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
                    if let user = self.parseJSON(userData: safeData) {
                        self.delegate?.didLogin(self, user: user)
                    }
                }
                
            }
            
            task.resume()
            
        }
    }
    
    func parseJSON(userData: Data) -> LoginUserResponse? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(LoginResponse.self, from: userData)
            return decodedData.data.loginUser
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}

protocol LoginManagerDelegate {
    func didLogin(_ loginManager: LoginManager, user: LoginUserResponse)
    
    func didFailWithError(error: Error)
}
