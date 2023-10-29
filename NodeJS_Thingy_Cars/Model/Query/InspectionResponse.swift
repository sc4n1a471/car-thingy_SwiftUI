//
//  InspectionResponse.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 10/28/23.
//

import Foundation

struct InspectionResponse: Codable, Hashable {
    var status: String
    var message: [Inspection]
    
    func isSuccess() -> Bool {
        return status == "success"
    }
}
