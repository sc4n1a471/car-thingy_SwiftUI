//
//  General.swift
//  car-thingy_SwiftUI
//
//  Created by Martin Terhes on 11/4/23.
//

import Foundation

struct General: Codable {
    var license_plate: String = String()
    var latitude: Double = Double()
    var longitude: Double = Double()
    var created_at: String = String()
}
