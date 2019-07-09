//
//  Contact.swift
//  APNSTest
//
//  Created by Francisco Diarte on 7/5/19.
//  Copyright © 2019 Francisco Diarte. All rights reserved.
//

import Foundation

struct Contact {    
    let deviceName: String
    let deviceToken: String
    
    var contactForDisplay: String {
        return "\(deviceName) - \(deviceToken)"
    }
}
