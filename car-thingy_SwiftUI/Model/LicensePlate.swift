//
//  LicensePlate.swift
//  car-thingy_SwiftUI
//
//  Created by Martin Terhes on 11/5/23.
//

import Foundation

struct LicensePlate: Codable, Equatable, Hashable {
    var license_plate: String = String()
    var comment: String = String()
    var created_at: String?
	
	func getDate() -> Date {
		if created_at != nil {
			let calendar = Calendar.autoupdatingCurrent
			if created_at!.contains("-") && created_at!.contains(":") {
				var dateTimeSeparated = created_at!.split(separator: "yas") // just for var init lol
				if created_at!.contains(" ") {
					dateTimeSeparated = created_at!.split(separator: " ")
				} else {
					dateTimeSeparated = created_at!.split(separator: "T")
				}
				let dateSeparated = dateTimeSeparated[0].split(separator: "-")
				let timeSeparated = dateTimeSeparated[1].split(separator: ":")
				return calendar.date(from: DateComponents(year: Int(dateSeparated[0]), month: Int(dateSeparated[1]), day: Int(dateSeparated[2]), hour: Int(timeSeparated[0]), minute: Int(timeSeparated[1])))!
			}
		}
		return Date.now
	}
}
