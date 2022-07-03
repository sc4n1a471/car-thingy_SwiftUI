//
//  Response.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/3/22.
//

import Foundation

struct Response: Codable {
    var status: String
    var message: [Cars]
}

//struct Response_failed: Codable {
//    var status: String
//    var message: String
//}
