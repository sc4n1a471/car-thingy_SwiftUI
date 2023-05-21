//
//  Mileage.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 5/21/23.
//

import Foundation

struct Mileage: Codable, Identifiable {
    
    var id: String {
        String(mileage)
    }
    
    var mileage: Int
    var mileageDate: String
    
    
    init(mileage: Int, mileageDate: String) {
//        let calendar = Calendar.autoupdatingCurrent
//        let dateSeperated = mileageDate.split(separator: ".")
//        self.mileageDate = calendar.date(from: DateComponents(year: Int(dateSeperated[0]), month: Int(dateSeperated[1]), day: Int(dateSeperated[2])))!
        self.mileageDate = mileageDate

        self.mileage = mileage
    }
}
