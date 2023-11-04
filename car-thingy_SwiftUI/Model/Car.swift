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
        specs.license_plate
    }
    var accidents: [Accident]?
    var specs: Specs = Specs()
    var restrictions: [Restriction]?
    var mileage: [Mileage]?
    var general: General = General()
    var inspections: [Inspection]?
    
    func getLP() -> String {
        var formattedLicensePlate = self.specs.license_plate.uppercased()
        
        if (formattedLicensePlate != "ERROR") {
            var numOfLetters = 0
            
            for char in formattedLicensePlate {
                if (char.isLetter) {
                    numOfLetters += 1
                }
            }
            
            formattedLicensePlate.insert(contentsOf: "-", at: formattedLicensePlate.index(formattedLicensePlate.startIndex, offsetBy: numOfLetters))
            
                // if it's the new license plate
            if (self.specs.license_plate.count > 6) {
                formattedLicensePlate.insert(contentsOf: " ", at: formattedLicensePlate.index(formattedLicensePlate.startIndex, offsetBy: 2))
            }
        }
        
        return formattedLicensePlate
    }
    
    func getLocation() -> MKCoordinateRegion {
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: self.general.latitude, longitude: self.general.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
}
