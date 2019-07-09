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
    
    static func sendNotification(contact: String, bundleId: String, payload: String, privateKey: String, teamId: String, keyId: String, apnsEnviornment: APNSEnviornment, success: @escaping() -> Void, failure: @escaping(Error) -> Void) {
        
        let urlString = apnsEnviornment == .sandbox ? "https://api.sandbox.push.apple.com:443/3/device/" : "https://api.push.apple.com:443/3/device/"
        
        guard let url = URL(string: urlString + contact) else { return }
        
        let signer = JWTSigner.es256(privateKey: Data(privateKey.utf8))
        let claims = ClaimsStandardJWT(iss: teamId, iat: Date())
        let header = Header(kid: keyId)
        var jwt = JWT(header: header, claims: claims)
        
        let signedJWT = try! jwt.sign(using: signer)
        
        let headers: [String: String] = ["Content-Type": "application/json",
                                         "Authorization": "bearer \(signedJWT)",
                                         "apns-expiration": "0",
                                         "apns-priority": "10",
                                         "apns-topic": bundleId]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = Data(payload.utf8)
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
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
                
                guard let apnsError = try? JSONDecoder().decode(APNSError.self, from: data) else {
                    let error = APNSError(reason: "Data response is in wrong format")
                    print(decodedString)
                    failure(error)
                    return
                }
                
                print(decodedString)
                failure(apnsError)
            }
            
        }.resume()
    }
}

extension String {
    func encodeToJSONData() -> Data? {
        guard let jsonData = try? JSONEncoder().encode(self) else { return nil }
        return jsonData
    }
}
