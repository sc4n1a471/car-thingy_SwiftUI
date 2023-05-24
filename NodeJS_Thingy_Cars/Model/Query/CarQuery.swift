//
//  CarQuery.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 5/21/23.
//

import Foundation

struct CarQuery: Codable {
    var accidents: [Accident]
    var brand: String
    var color: String
    var engine_size: Int
    
    var first_reg: String
    var first_reg_hun: String
    
    var fuel_type: String
    var gearbox: String
    
    var inspections: [Inspection]
    
    var license_plate: String
    
    var mileage: [Mileage]
    
    var model: String
    var num_of_owners: Int
    var performance: Int
    
    var restrictions: [String]
    
    var status: String
    var type_code: String
    var year: Int    
}

