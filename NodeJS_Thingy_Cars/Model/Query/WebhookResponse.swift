//
//  WebhookResponse.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 10/10/23.
//

import Foundation

struct WebhookResponse: Codable {    
    var status: String
    var percentage: Double
    var key: String?
    var value: String?
    var message: String?
}
