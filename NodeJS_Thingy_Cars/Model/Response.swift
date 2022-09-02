//
//  Response.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/3/22.
//

import Foundation

struct Response: Codable {
    var success: Bool
    var message: String?
    var cars: [Car]?
    var brands: [Brand]?
}

//struct Response_failed: Codable {
//    var status: String
//    var message: String
//}
