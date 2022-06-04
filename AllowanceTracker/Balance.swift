//
//  Balance.swift
//  AllowanceTracker
//
//  Created by Spud on 6/3/22.
//

import Foundation

struct Balance: Codable {
    var amount: Double
    var lastKnownDate: Date
}
