//
//  App.swift
//  APNSTest
//
//  Created by Francisco Diarte on 7/5/19.
//  Copyright © 2019 Francisco Diarte. All rights reserved.
//

import Foundation

struct App {
    let name: String
    let bundleId: String
    
    var appForDisplay: String {
        return "\(name) - \(bundleId)"
    }
}
