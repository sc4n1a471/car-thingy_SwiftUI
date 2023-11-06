//
//  LicensePlate.swift
//  car-thingy_SwiftUI
//
//  Created by Martin Terhes on 11/5/23.
//

import Foundation

struct LicensePlate: Codable {
    var license_plate: String = String()
    var comment: String = String()
    var created_at: String?
}
