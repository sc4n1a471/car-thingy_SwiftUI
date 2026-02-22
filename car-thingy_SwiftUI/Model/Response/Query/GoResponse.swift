//
//  GoResponse.swift
//  car-thingy_SwiftUI
//
//  Created by Martin Terhes on 11/6/23.
//

import Foundation

struct GoResponse: Decodable {
    var status: String
    var message: String?
	var data: String?
}
