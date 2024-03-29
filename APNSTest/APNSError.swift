//
//  APNSError.swift
//  APNSTest
//
//  Created by Francisco Diarte on 7/5/19.
//  Copyright © 2019 Francisco Diarte. All rights reserved.
//

import Foundation

struct APNSError: Error, Decodable {
    let reason: String
    var errorCode: Int?
    
    init(reason: String, errorCode: Int? = nil) {
        self.reason = reason
        self.errorCode = errorCode
    }
}
