//
//  Mileage.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 5/21/23.
//

import Foundation

struct Mileage: Codable, Identifiable, Equatable, Hashable {
    
    var id: String {
        String(mileage)
    }
    
    var licensePlate: String?
    var mileage: Int
    var date: String
    var animate: Bool?
    
    init(mileage: Int = Int(), date: String = String(), licensePlate: String = String()) {
        self.date = date
        self.mileage = mileage
        self.licensePlate = licensePlate
    }
    
    func getDate(_ yearMonthOnly: Bool = false) -> Date {
        let calendar = Calendar.autoupdatingCurrent
        if date.contains(".") {
            let dateSeparated = date.split(separator: ".")
            if yearMonthOnly {
                return calendar.date(from: DateComponents(year: Int(dateSeparated[0]), month: Int(dateSeparated[1])))!
            } else {
                return calendar.date(from: DateComponents(year: Int(dateSeparated[0]), month: Int(dateSeparated[1]), day: Int(dateSeparated[2])))!
            }
        }
        return Date.now
    }
    
    func getYear() -> Int {
        if date.contains(".") {
            let dateSeparated = date.split(separator: ".")
            return Int(dateSeparated[0])!
        }
        return 0
    }
    
    func hasValidMileage() -> Bool {
        return date.contains(".")
    }
    
    func getDateComponents() -> DateComponents {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: getDate())
        return components
    }
}
