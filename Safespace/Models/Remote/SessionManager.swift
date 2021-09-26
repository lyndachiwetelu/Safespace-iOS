//
//  SessionManager.swift
//  Safespace
//
//  Created by Lynda Chiwetelu on 24.09.21.
//

import Foundation

struct SessionManager: UsesUserDefaults {
    var delegate: SessionManagerDelegate?
    var fetchDelegate: SessionManagerFetchDelegate?
    
    func createSessions(sessions: [SessionRequest]) {
        for session in sessions {
            createSession(session: session)
        }
        self.delegate?.didEndCreation(self, ended: true)
    }
    
    func getUserSessions(userId: Int) {
        performGetRequest(userId: userId)
    }
    
    private func createSession(session: SessionRequest) {
        performRequest(session: session)
    }
    
    func performGetRequest(userId: Int) {
        if let url = URL(string: AppConstant.baseGqlUrl) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            let accessToken = getUserDefault(key: AppConstant.apiToken)
            request.setValue(accessToken, forHTTPHeaderField: "access-token")
            
            let requestBodyDict = [
                "query": """
                    query fetchSessions {
                        getUserSessions(id: \(userId)) {
                            availabilityId
                            day
                            from
                            id
                            requestedBy
                            status
                            therapistInfo {
                              id
                              name
                                therapistSetting {
                                    imageUrl
                                }
                            }
                            to
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
                    if let sessions = self.parseSessionsJSON(sessions: safeData) {
                        self.fetchDelegate?.didFetchSessions(self, sessions: sessions)
                    }
                }
                
            }
            
            task.resume()
            
        }
    }
    
    func performRequest(session: SessionRequest) {
        if let url = URL(string: AppConstant.baseGqlUrl) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            let accessToken = getUserDefault(key: AppConstant.apiToken)
            request.setValue(accessToken, forHTTPHeaderField: "access-token")
            
            let requestBodyDict = [
                "query": """
                   mutation createsession {
                     createSession(
                       input: {
                        availabilityId: \(session.availabilityId),
                        from: "\(session.from)",
                        requestedBy: \(session.requestedBy),
                        status: "\(session.status)",
                        to: "\(session.to)" }
                     ) {
                       status
                           id
                           from
                           to
                           requestedBy
                           availabilityId
                           day
                           therapist {
                             id
                             name
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
                    if let session = self.parseJSON(session: safeData) {
                        self.delegate?.didCreateSession(self, session: session)
                    }
                }
                
            }
            
            task.resume()
            
        }
    }
    
    func parseJSON(session: Data) -> SessionResponse? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CreateSessionResponse.self, from: session)
            return decodedData.data.createSession
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func parseSessionsJSON(sessions: Data) -> [UserSessionResponse]? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(GetSessionsResponse.self, from: sessions)
            return decodedData.data.getUserSessions
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}

protocol SessionManagerDelegate {
    func didEndCreation(_ sManager: SessionManager, ended: Bool)
    func didCreateSession(_ sManager: SessionManager, session: SessionResponse)
    func didFailWithError(error: Error)
}

protocol SessionManagerFetchDelegate {
    func didFetchSessions(_ sManager: SessionManager, sessions: [UserSessionResponse]?)
    func didFailWithError(error: Error)
}


