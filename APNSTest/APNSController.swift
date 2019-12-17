//
//  APNSController.swift
//  APNSTest
//
//  Created by Francisco Diarte on 7/3/19.
//  Copyright © 2019 Francisco Diarte. All rights reserved.
//

import Foundation
import SwiftJWT

class APNSController {
    
    private let dateKey = "ISSUED_DATE"
    private var token: String? = nil
    
    func sendNotification(contact: String, bundleId: String, payload: String, privateKey: String, teamId: String, keyId: String, apnsEnviornment: APNSEnviornment, pushType: String, success: @escaping() -> Void, failure: @escaping(Error) -> Void) {
        
        let urlString = apnsEnviornment == .sandbox ? "https://api.sandbox.push.apple.com:443/3/device/" : "https://api.push.apple.com:443/3/device/"
        
        guard let url = URL(string: urlString + contact) else { return }
        
        checkSavedTime(privateKey: privateKey, teamId: teamId, keyId: keyId)
        
        let apnsToken = token ?? createNewToken(privateKey: privateKey, teamId: teamId, keyId: keyId)
        self.token = apnsToken
        
        let headers: [String: String] = ["Content-Type": "application/json",
                                         "Authorization": "bearer \(apnsToken)",
                                         "apns-expiration": "0",
                                         "apns-priority": "10",
                                         "apns-push-type": pushType,
                                         "apns-topic": bundleId]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = Data(payload.utf8)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                failure(error)
                return
            }

            guard let data = data else { return }
            
            DispatchQueue.main.async {
                guard let decodedString = String(data: data, encoding: .utf8) else {
                    let genericError = APNSError(reason: "Unable to decode response")
                    failure(genericError)
                    return
                }
                
                guard !decodedString.isEmpty else {
                    success()
                    return
                }
                
                guard var apnsError = try? JSONDecoder().decode(APNSError.self, from: data) else {
                    let error = APNSError(reason: "Data response is in wrong format")
                    print(decodedString)
                    failure(error)
                    return
                }
                
                let errorCode = (response as? HTTPURLResponse)?.statusCode
                apnsError.errorCode = errorCode
                print(decodedString)
                failure(apnsError)
            }
            
        }.resume()
    }
    
    private func createNewToken(privateKey: String, teamId: String, keyId: String) -> String {
        let signer = JWTSigner.es256(privateKey: Data(privateKey.utf8))
        let claims = ClaimsStandardJWT(iss: teamId, iat: Date())
        let header = Header(kid: keyId)
        var jwt = JWT(header: header, claims: claims)
        
        return try! jwt.sign(using: signer)
    }
    
    private func checkSavedTime(privateKey: String, teamId: String, keyId: String) {
        let now = Date()
        let hourInSeconds = 3600.0
        
        guard let savedDate = UserDefaults.standard.value(forKey: dateKey) as? Date else {
            UserDefaults.standard.set(now, forKey: dateKey)
            UserDefaults.standard.synchronize()
            self.token = createNewToken(privateKey: privateKey, teamId: teamId, keyId: keyId)
            return
        }
        
        if (savedDate.timeIntervalSince1970 - now.timeIntervalSince1970) > hourInSeconds {
            UserDefaults.standard.set(now, forKey: dateKey)
            UserDefaults.standard.synchronize()
            
            self.token = createNewToken(privateKey: privateKey, teamId: teamId, keyId: keyId)
        }
    }
}
