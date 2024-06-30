//
//  Car.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/3/22.
//

import Foundation
import MapKit

enum DateType {
	case createdAt
	case updatedAt
}

struct Car: Codable, Identifiable, Equatable, Hashable {
    var id: String {
        licensePlate
    }
	var licensePlate: String = String()
	var comment: String = String()
	var createdAt: String?
	var updatedAt: String?
	var brand: String?
	var color: String?
	var engineSize: Int?
	var firstReg: String?
	var firstRegHun: String?
	var fuelType: String?
	var gearbox: String?
	var model: String?
	var numOfOwners: Int?
	var performance: Int?
	var status: String?
	var typeCode: String?
	var year: Int?
	var latitude: Double = Double()
	var longitude: Double = Double()
	
	var accidents: [Accident]?
	var restrictions: [Restriction]?
	var mileage: [Mileage] = [Mileage()]
	var inspections: [Inspection]?
	
	var parsedCreatedAt: Date?
	var parsedUpdatedAt: Date?
	
	mutating func getDate(_ dateType: DateType) -> Date? {
		switch dateType {
			case .createdAt:
				if createdAt != nil {
					if let safeParsedCreatedAt = parsedCreatedAt {
						return safeParsedCreatedAt
					}
					
					let calendar = Calendar.autoupdatingCurrent
					if createdAt!.contains("-") && createdAt!.contains(":") {
						var dateTimeSeparated = createdAt!.split(separator: "yas") // just for var init lol
						if createdAt!.contains(" ") {
							dateTimeSeparated = createdAt!.split(separator: " ")
						} else {
							dateTimeSeparated = createdAt!.split(separator: "T")
						}
						let dateSeparated = dateTimeSeparated[0].split(separator: "-")
						let timeSeparated = dateTimeSeparated[1].split(separator: ":")
						parsedCreatedAt = calendar.date(from: DateComponents(year: Int(dateSeparated[0]), month: Int(dateSeparated[1]), day: Int(dateSeparated[2]), hour: Int(timeSeparated[0]), minute: Int(timeSeparated[1])))!
						return parsedCreatedAt
					}
				}
			case .updatedAt:
				if updatedAt != nil {
					if let safeParsedUpdatedAt = parsedUpdatedAt {
						return safeParsedUpdatedAt
					}
					
					let calendar = Calendar.autoupdatingCurrent
					if updatedAt!.contains("-") && updatedAt!.contains(":") {
						var dateTimeSeparated = updatedAt!.split(separator: "yas") // just for var init lol
						if updatedAt!.contains(" ") {
							dateTimeSeparated = updatedAt!.split(separator: " ")
						} else {
							dateTimeSeparated = updatedAt!.split(separator: "T")
						}
						let dateSeparated = dateTimeSeparated[0].split(separator: "-")
						let timeSeparated = dateTimeSeparated[1].split(separator: ":")
						parsedUpdatedAt = calendar.date(from: DateComponents(year: Int(dateSeparated[0]), month: Int(dateSeparated[1]), day: Int(dateSeparated[2]), hour: Int(timeSeparated[0]), minute: Int(timeSeparated[1])))!
						return parsedUpdatedAt
					}
				}
		}
		return nil
	}
	
    func getLP() -> String {
        var formattedLicensePlate = self.licensePlate.uppercased()
        
        if (formattedLicensePlate != "ERROR") {
            var numOfLetters = 0
            
            for char in formattedLicensePlate {
                if (char.isLetter) {
                    numOfLetters += 1
                }
            }
            
            formattedLicensePlate.insert(contentsOf: "-", at: formattedLicensePlate.index(formattedLicensePlate.startIndex, offsetBy: numOfLetters))
            
                // if it's the new license plate
            if (self.licensePlate.count > 6) {
                formattedLicensePlate.insert(contentsOf: " ", at: formattedLicensePlate.index(formattedLicensePlate.startIndex, offsetBy: 2))
            }
        }
        
        return formattedLicensePlate
    }
    
    func getLocation() -> MKCoordinateRegion {
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
    
    func toString() {
        print(self.licensePlate)
        print(self.accidents as Any)
//        print(self.specs)
        print(self.restrictions as Any)
        print(self.mileage as Any)
//        print(self.coordinates)
    }
}
