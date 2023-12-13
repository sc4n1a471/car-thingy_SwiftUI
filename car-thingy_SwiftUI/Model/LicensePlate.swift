//
//  LicensePlate.swift
//  car-thingy_SwiftUI
//
//  Created by Martin Terhes on 11/5/23.
//

import Foundation

enum DateType {
	case createdAt
	case updatedAt
}

struct LicensePlate: Codable, Equatable, Hashable {
    var license_plate: String = String()
    var comment: String = String()
    var created_at: String?
	var updated_at: String?
	var parsedCreatedAt: Date?
	var parsedUpdatedAt: Date?
	
	mutating func getDate(_ dateType: DateType) -> Date? {
		switch dateType {
			case .createdAt:
				if created_at != nil {
					if let safeParsedCreatedAt = parsedCreatedAt {
						return safeParsedCreatedAt
					}
					
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
						parsedCreatedAt = calendar.date(from: DateComponents(year: Int(dateSeparated[0]), month: Int(dateSeparated[1]), day: Int(dateSeparated[2]), hour: Int(timeSeparated[0]), minute: Int(timeSeparated[1])))!
						return parsedCreatedAt
					}
				}
			case .updatedAt:
				if updated_at != nil {
					if let safeParsedUpdatedAt = parsedUpdatedAt {
						return safeParsedUpdatedAt
					}
					
					let calendar = Calendar.autoupdatingCurrent
					if updated_at!.contains("-") && updated_at!.contains(":") {
						var dateTimeSeparated = updated_at!.split(separator: "yas") // just for var init lol
						if updated_at!.contains(" ") {
							dateTimeSeparated = updated_at!.split(separator: " ")
						} else {
							dateTimeSeparated = updated_at!.split(separator: "T")
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
}
