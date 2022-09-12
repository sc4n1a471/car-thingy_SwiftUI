//
//  Car.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/3/22.
//

import Foundation
import MapKit

struct Car: Codable, Identifiable {
    var id: String {
        license_plate
    }
    var license_plate: String
    
    var brand_id: Int
    var brand: String
    var model: String
    var codename: String
    var year: Int
    var comment: String
    var is_new: Int
    var latitude: Double
    var longitude: Double
    
    var hasBrand: Bool {
        if (brand != "DEFAULT_VALUE" && brand != "") {
            return true
        } else {
            return false
        }
    }
    var hasModel: Bool {
        if (model != "DEFAULT_VALUE" && model != "") {
            return true
        } else {
            return false
        }
    }
    var hasCodename: Bool {
        if (codename != "DEFAULT_VALUE" && codename != "") {
            return true
        } else {
            return false
        }
    }
    var hasYear: Bool {
        if (year != 1901 && year != Int("")) {
            return true
        } else {
            return false
        }
    }
    var hasComment: Bool {
        if (comment != "DEFAULT_VALUE" && comment != "") {
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
            
            // if it's the new license plate
            if (self.license_plate.count > 6) {
                formattedLicensePlate.insert(contentsOf: " ", at: formattedLicensePlate.index(formattedLicensePlate.startIndex, offsetBy: 2))
            }
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
    func getLocation() -> MKCoordinateRegion {
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    }
}
