//
//  Restriction.swift
//  car-thingy_SwiftUI
//
//  Created by Martin Terhes on 11/4/23.
//

import Foundation

struct Restriction: Codable, Equatable, Hashable {
    var id: String {
        restriction
    }
    var license_plate: String = String()
    var restriction: String = String()
    var restriction_date: String = String()
    var active: Bool = Bool()
}
