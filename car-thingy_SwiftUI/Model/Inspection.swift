//
//  CarQueryInspection.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 5/21/23.
//

import Foundation

struct Inspection: Codable, Hashable {
    var license_plate = String()
    var name: String = String()
    var base_64: [String]?
}
