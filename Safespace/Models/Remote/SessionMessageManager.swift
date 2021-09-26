//
//  SessionMessageManager.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 24.09.21.
//

import Foundation


struct SessionMessageManager: UsesUserDefaults {
    var delegate: SessionMessageManagerDelegate?
    var fetchDelegate: SessionMessageManagerFetchDelegate?
    
    func createSessionMessage(sessionId: Int, message: SessionMessageRequest) {
        performRequest(sessionId: sessionId, message: message)
    }
    
    func getSessionMessages(sessionId: Int) {
        performGetRequest(sessionId: sessionId)
    }
    
    func performGetRequest(sessionId: Int) {
        if let url = URL(string: AppConstant.baseGqlUrl) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            let accessToken = getUserDefault(key: AppConstant.apiToken)
            request.setValue(accessToken, forHTTPHeaderField: "access-token")
            
            let requestBodyDict = [
                "query": """
                    query fetchSessionMessages {
                        getSessionMessages(id: \(sessionId)) {
                            message
                            createdAt
                            id
                            sessionId
                            userId
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
                    self.fetchDelegate?.didFailWithError(error: error!)
                }
                
                if let safeData = data {
                    if let messages = self.parseMessagesJSON(messages: safeData) {
                        self.fetchDelegate?.didFetchMessages(self, messages: messages)
                    }
                }
                
            }
            
            task.resume()
            
        }
    }
    
    func performRequest(sessionId: Int, message: SessionMessageRequest) {
        if let url = URL(string: AppConstant.baseGqlUrl) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            let accessToken = getUserDefault(key: AppConstant.apiToken)
            request.setValue(accessToken, forHTTPHeaderField: "access-token")
            
            let requestBodyDict = [
                "query": """
                   mutation createSessionMessage {
                     saveSessionMessage(input: { message: "\(message.message)", userId: \(message.userId) }, id: \(sessionId) ) {
                         createdAt
                         id
                         message
                         sessionId
                         userId
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
                    if let message = self.parseJSON(message: safeData) {
                        self.delegate?.didCreateSessionMessage(self, message: message)
                    }
                }
                
            }
            
            task.resume()
            
        }
    }
    
    func parseJSON(message: Data) -> SessionMessageResponse? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CreateSessionMessageResponse.self, from: message)
            return decodedData.data.saveSessionMessage
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func parseMessagesJSON(messages: Data) -> [SessionMessageResponse]? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(GetSessionMessagesResponse.self, from: messages)
            return decodedData.data.getSessionMessages
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}

protocol SessionMessageManagerDelegate {
    func didCreateSessionMessage(_ smManager: SessionMessageManager, message: SessionMessageResponse)
    func didFailWithError(error: Error)
}

protocol SessionMessageManagerFetchDelegate {
    func didFetchMessages(_ smManager: SessionMessageManager, messages: [SessionMessageResponse]?)
    func didFailWithError(error: Error)
}



