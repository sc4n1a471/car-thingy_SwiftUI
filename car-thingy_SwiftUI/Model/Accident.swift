//
//  Accident.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 5/24/23.
//

import Foundation

struct Accident: Codable, Hashable {
    var license_plate: String = String()
    var accident_date: String = String()
    var role: String = String()
}
