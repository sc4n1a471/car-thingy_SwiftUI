//
//  CarQueryInspection.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 5/21/23.
//

import Foundation

enum NameParseTypes {
	case name
	case date
}

struct Inspection: Codable, Hashable {
    var licensePlate = String()
    var name: String = String()
	var imageLocation: String = String()
    var base64: [String]?
	
	func parseName(_ returnValue: NameParseTypes) -> String {
		let nameSplit = name.split(separator: ",")
		if returnValue == .date {
			if nameSplit.isEmpty {
				return "2000.01.01."
			}
			return String(nameSplit[1].replacingOccurrences(of: " ", with: ""))
		} else if returnValue == .name {
			if nameSplit.isEmpty {
				return ""
			}
			return String(nameSplit[0].replacingOccurrences(of: "MŰSZAKI VIZSGÁLAT", with: "Műszaki vizsga").replacingOccurrences(of: "ELŐZETES EREDETISÉGVIZSGÁLAT", with: "Eredetiség vizsga"))
		}
		return "dafaq"
	}
}
