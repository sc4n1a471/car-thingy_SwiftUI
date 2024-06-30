//
//  CarQueryInspection.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 5/21/23.
//

import Foundation

struct Inspection: Codable, Hashable {
    var licensePlate = String()
    var name: String = String()
	var imageLocation: String = String()
    var base64: [String]?
}
