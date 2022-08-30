//
//  Car.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/3/22.
//

import Foundation

struct Car: Codable {
    
    var license_plate: String
    
    var brand_id: Int
    var brand: String
    var model: String
    var codename: String
    var year: Int
    var comment: String
    var is_new: Int
    
    var hasBrand: Bool {
        if (brand == "DEFAULT_VALUE") {
            return false
        } else {
            return true
        }
    }
    var hasModel: Bool {
        if (model == "DEFAULT_VALUE") {
            return false
        } else {
            return true
        }
    }
    var hasCodename: Bool {
        if (codename == "DEFAULT_VALUE") {
            return false
        } else {
            return true
        }
    }
    var hasYear: Bool {
        if (year != 1901) {
            return true
        } else {
            return false
        }
    }
    var hasComment: Bool {
        if (comment != "DEFAULT_VALUE") {
            return true
        } else {
            return false
        }
    }
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
        }
        
        return formattedLicensePlate
    }
    func isNew() -> Bool {
        if (is_new == 1) {
            return true
        } else {
            return false
        }
    }
}
