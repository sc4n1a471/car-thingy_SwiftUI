//
//  CarQuery.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 5/21/23.
//

import Foundation

struct CarQuery: Codable {
    var accidents: [Accident]?
    var brand: String
    var color: String
    var engine_size: Int
    var first_reg: String
    var first_reg_hun: String
    var fuel_type: String
    var gearbox: String
    var inspections: [Inspection]?
    var license_plate: String
    var mileage: [Mileage]?
    var model: String
    var num_of_owners: Int
    var performance: Int
    var restrictions: [String]?
    var status: String
    var type_code: String
    var year: Int
    
    func getLP() -> String {
        var formattedLicensePlate = self.license_plate.uppercased()
        
        if (formattedLicensePlate != "ERROR") {
            var numOfLetters = 0
            
            for char in formattedLicensePlate {
                if (char.isLetter) {
                    numOfLetters += 1
                }
            }
            
            formattedLicensePlate.insert(contentsOf: "-", at: formattedLicensePlate.index(formattedLicensePlate.startIndex, offsetBy: numOfLetters))
            
            // if it's the new license plate
            if (self.license_plate.count > 6) {
                formattedLicensePlate.insert(contentsOf: " ", at: formattedLicensePlate.index(formattedLicensePlate.startIndex, offsetBy: 2))
            }
        }
        
        return formattedLicensePlate
    }
}

