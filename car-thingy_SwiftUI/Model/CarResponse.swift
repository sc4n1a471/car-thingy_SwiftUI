//
//  Response.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/3/22.
//

import Foundation

struct CarResponse: Codable {
	var data: [Car]?
    var message: String?
    var status: String
}
 
