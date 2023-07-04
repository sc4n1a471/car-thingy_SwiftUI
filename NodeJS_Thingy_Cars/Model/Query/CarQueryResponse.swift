//
//  CarQueryResponse.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 5/21/23.
//

import Foundation

struct CarQueryResponse: Codable {
    var message: [CarQuery]?
    var status: String
    var error: String?
}
