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
        license_plate.license_plate
    }
    var license_plate: LicensePlate = LicensePlate()
    var accidents: [Accident]?
    var specs: Specs = Specs()
    var restrictions: [Restriction]?
    var mileage: [Mileage] = [Mileage()]
    var coordinates: Coordinates = Coordinates()
    var inspections: [Inspection] = [Inspection()]
    
    func getLP() -> String {
        var formattedLicensePlate = self.license_plate.license_plate.uppercased()
        
        if (formattedLicensePlate != "ERROR") {
            var numOfLetters = 0
            
            for char in formattedLicensePlate {
                if (char.isLetter) {
                    numOfLetters += 1
                }
            }
            
            formattedLicensePlate.insert(contentsOf: "-", at: formattedLicensePlate.index(formattedLicensePlate.startIndex, offsetBy: numOfLetters))
            
                // if it's the new license plate
            if (self.license_plate.license_plate.count > 6) {
                formattedLicensePlate.insert(contentsOf: " ", at: formattedLicensePlate.index(formattedLicensePlate.startIndex, offsetBy: 2))
            }
        }
        
        return formattedLicensePlate
    }
    
    func getLocation() -> MKCoordinateRegion {
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: self.coordinates.latitude, longitude: self.coordinates.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
    
    func toString() {
        print(self.license_plate)
        print(self.accidents as Any)
        print(self.specs)
        print(self.restrictions as Any)
        print(self.mileage as Any)
        print(self.coordinates)
    }
}
