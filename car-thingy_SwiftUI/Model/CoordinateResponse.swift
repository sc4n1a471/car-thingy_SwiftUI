//
//  CoordinateResponse.swift
//  car-thingy_SwiftUI
//
//  Created by Martin Terhes on 11/11/23.
//

import Foundation

struct CoordinateResponse: Codable {
    var message: [Coordinates]
    var status: String
}
