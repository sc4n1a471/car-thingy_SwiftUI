//
//  Car.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/3/22.
//

import Foundation

struct Car: Codable {
    
    var license_plate: String
    

    var brand: String
    var model: String
    var codename: String?
    var year: Int?
    var comment: String?
    
    var hasCodename: Bool {
        if (codename == "") {
            return false
        } else {
            return true
        }
    }
    
    var hasYear: Bool {
        if (year != 0) {
            return true
        } else {
            return false
        }
    }
    
    var hasComment: Bool {
        if (comment != "null") {
            return true
        } else {
            return false
        }
    }
    
    func getLP() -> String {
        var formattedLicensePlate = self.license_plate.uppercased()
        var numOfLetters = 0
        
        for char in formattedLicensePlate {
            if (char.isLetter) {
                numOfLetters += 1
            }
        }
        
        formattedLicensePlate.insert(contentsOf: "-", at: formattedLicensePlate.index(formattedLicensePlate.startIndex, offsetBy: numOfLetters))
        
        return formattedLicensePlate
    }
}
