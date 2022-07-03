//
//  Car.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/3/22.
//

import Foundation

struct Cars: Codable {
    
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
        if (comment != "") {
            return true
        } else {
            return false
        }
    }
    
    func getLP() -> String {
        var formattedLicensePlate = self.license_plate
        var numOfLetters = 0
        
        for char in formattedLicensePlate {
            if (char.isLetter) {
                numOfLetters += 1
            }
        }
        
        formattedLicensePlate.insert(contentsOf: "-", at: formattedLicensePlate.index(formattedLicensePlate.startIndex, offsetBy: numOfLetters))
        
        return formattedLicensePlate
    }
    
//    mutating func setLP(lp: String) {
//        var formattedLicensePlate = lp
////        var formattedLicensePlateArray: Array<String> = []
////        for char in self.license_plate {
////            formattedLicensePlateArray.append(String(char))
////        }
//        formattedLicensePlate.insert(contentsOf: "-", at: formattedLicensePlate.index(formattedLicensePlate.startIndex, offsetBy: 3))
//        license_plate = formattedLicensePlate
//    }
    
//    init(license_plate_new: String, brand: String, model: String, codename: String? = nil, year: Int? = nil, comment: String? = nil) {
//        self.license_plate = license_plate_new
//
//        self.license_plate.insert(contentsOf: "-", at: self.license_plate.index(self.license_plate.startIndex, offsetBy: 3))
//
//        self.brand = brand
//        self.model = model
//        self.codename = codename
//        self.year = year
//        self.comment = comment
//    }
}

//struct Car: View {
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}
//
//struct Car_Previews: PreviewProvider {
//    static var previews: some View {
//        Car()
//    }
//}
