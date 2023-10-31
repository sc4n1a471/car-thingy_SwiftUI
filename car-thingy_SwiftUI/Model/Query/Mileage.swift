//
//  Mileage.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 5/21/23.
//

import Foundation

struct Mileage: Codable, Identifiable, Equatable {
    
    var id: String {
        String(mileage)
    }
    
    var mileage: Int
    var mileage_date: String
    var animate: Bool?
    
    init(mileage: Int = Int(), mileageDate: String = String()) {
        self.mileage_date = mileageDate
        self.mileage = mileage
    }
    
    func getDate(_ yearMonthOnly: Bool = false) -> Date {
        let calendar = Calendar.autoupdatingCurrent
        if mileage_date.contains(".") {
            let dateSeperated = mileage_date.split(separator: ".")
            if yearMonthOnly {
                return calendar.date(from: DateComponents(year: Int(dateSeperated[0]), month: Int(dateSeperated[1])))!
            } else {
                return calendar.date(from: DateComponents(year: Int(dateSeperated[0]), month: Int(dateSeperated[1]), day: Int(dateSeperated[2])))!
            }
        }
        return Date.now
    }
    
    func getYear() -> Int {
        if mileage_date.contains(".") {
            let dateSeperated = mileage_date.split(separator: ".")
            return Int(dateSeperated[0])!
        }
        return 0
    }
    
    func hasValidMileage() -> Bool {
        return mileage_date.contains(".")
    }
    
    func getDateComponents() -> DateComponents {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: getDate())
        print(components.year)
        return components
    }
}
