//
//  Accident.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 5/24/23.
//

import Foundation

struct Accident: Codable, Hashable {
    var licensePlate: String = String()
    var accidentDate: String = String()
    var role: String = String()
}
