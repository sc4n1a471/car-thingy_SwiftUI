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
    var errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case status
        case percentage
        case key
        case value
        case errorMessage
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.status = try container.decode(String.self, forKey: .status)
        self.percentage = try container.decode(Double.self, forKey: .percentage)
        
        if self.status == "pending" {
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
                    let messageCuccli = try container.decode(String.self, forKey: .value)
                    self.value = .message(messageCuccli)
                case .engine_size, .num_of_owners, .performance, .year:
                    let intCuccli = try container.decode(Int.self, forKey: .value)
                    self.value = .intValue(intCuccli)
                case .brand, .color, .first_reg, .first_reg_hun, .fuel_type, .gearbox, .model, .status, .type_code, .license_plate:
                    let stringCuccli = try container.decode(String.self, forKey: .value)
                    self.value = .stringValue(stringCuccli)
                default:
                    let messageCuccli = try container.decode(String.self, forKey: .value)
                        //                    self.value = messageCuccli
                    break
            }
        } else if self.status == "fail" {
            let messageCuccli = try container.decode(String.self, forKey: .value)
            self.errorMessage = messageCuccli
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
    case license_plate
    
    case message
    case fail
}

enum WebsocketResponseType: Decodable {
    case accidents([Accident])
    case restrictions([String])
    case mileage([Mileage])
    case intValue(Int)
    case stringValue(String)
    case message(String)
    case errorMessage(String)
}
