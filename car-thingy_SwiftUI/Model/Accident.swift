//
//  Accident.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 5/24/23.
//

import Foundation

struct Accident: Codable, Hashable {
    var license_plate: String = String()
    var accident_date: String = String()
    var role: String = String()
	
	func getDate() -> Date {
		let calendar = Calendar.autoupdatingCurrent
		if accident_date.contains("-") {
			let dateTimeSeparated = accident_date.split(separator: "T")
			let dateSeparated = dateTimeSeparated[0].split(separator: "-")
			return calendar.date(from: DateComponents(year: Int(dateSeparated[0]), month: Int(dateSeparated[1])))!
		}
		return Date.now
	}
}
