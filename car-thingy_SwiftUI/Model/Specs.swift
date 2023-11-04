//
//  Specs.swift
//  car-thingy_SwiftUI
//
//  Created by Martin Terhes on 11/4/23.
//

import Foundation

struct Specs: Codable {
    var license_plate: String = String()
    var brand: String = String()
    var color: String = String()
    var engine_size: Int = Int()
    var first_reg: String = String()
    var first_reg_hun: String = String()
    var fuel_type: String = String()
    var gearbox: String = String()
    var model: String = String()
    var num_of_owners: Int = Int()
    var performance: Int = Int()
    var status: String = String()
    var type_code: String = String()
    var year: Int = Int()
    var comment: String = String()
}
