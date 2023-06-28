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
    var mileage_date: String
    
    
    init(mileage: Int, mileageDate: String) {
        self.mileage_date = mileageDate
        self.mileage = mileage
    }
    
    func getDate() -> Date {
        let calendar = Calendar.autoupdatingCurrent
        let dateSeperated = mileage_date.split(separator: ".")
        return calendar.date(from: DateComponents(year: Int(dateSeperated[0]), month: Int(dateSeperated[1]), day: Int(dateSeperated[2])))!
    }
    
    func getYear() -> Int {
        let dateSeperated = mileage_date.split(separator: ".")
        return Int(dateSeperated[0])!
    }
}
