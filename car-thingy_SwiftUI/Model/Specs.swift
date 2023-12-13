//
//  Specs.swift
//  car-thingy_SwiftUI
//
//  Created by Martin Terhes on 11/4/23.
//

import Foundation

struct Specs: Codable, Equatable, Hashable {
    var license_plate: String?
    var brand: String?
    var color: String?
    var engine_size: Int?
    var first_reg: String?
    var first_reg_hun: String?
    var fuel_type: String?
    var gearbox: String?
    var model: String?
    var num_of_owners: Int?
    var performance: Int?
    var status: String?
    var type_code: String?
    var year: Int?
}
