//
//  WebhookResponse.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 10/10/23.
//

import Foundation


struct WebsocketResponse: Decodable {
    var status: String
    var percentage: Double
    var key: CarDataType?
    var value: WebsocketResponseType?
//    var stringValue: String?
//    var accidents: [AccidentType]?
    var message: String?
    
    enum CodingKeys: String, CodingKey {
        case status
        case percentage
        case key
        case value
        case message
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.status = try container.decode(String.self, forKey: .status)
        self.percentage = try container.decode(Double.self, forKey: .percentage)
        
        if self.status != "success" {
            self.key = try container.decode(CarDataType.self, forKey: .key)
            
            switch self.key {
                case .accidents:
                    let accidents = try container.decode([Accident].self, forKey: .value)
                    self.value = .accidents(accidents)
                case .restrictions:
                    let restrictions = try container.decode([String].self, forKey: .value)
                    self.value = .restrictions(restrictions)
                case .mileage:
                    let mileage = try container.decode([Mileage].self, forKey: .value)
                    self.value = .mileage(mileage)
                case .message:
                    let message = try container.decode(String.self, forKey: .message)
                default:
                    let stringCuccli = try container.decode(String.self, forKey: .value)
                    self.value = .stringValue(stringCuccli)
            }
        }
    }
}

enum CarDataType: String, Codable, CodingKey {
    case brand
    case color
    case engine_size
    case first_reg
    case first_reg_hun
    case fuel_type
    case gearbox
    case model
    case num_of_owners
    case performance
    case status
    case type_code
    case year
    case accidents
    case restrictions
    case mileage
    
    case message
}

enum WebsocketResponseType: Decodable {
    case accidents([Accident])
    case restrictions([String])
    case mileage([Mileage])
    case stringValue(String)
    case message(String)
    case error(String)
}
