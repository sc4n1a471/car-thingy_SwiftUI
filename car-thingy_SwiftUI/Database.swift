//
//  Database.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/3/22.
//

import Foundation

let urlCars = "http://10.11.12.169:3011/cars"
//let urlCars = "http://10.11.12.109:3000/cars"
let urlBrands = "http://10.11.12.169/carBrands"
//let urlBrands = "http://10.11.12.109:3000/carBrands"
let urlCarQuery = "http://10.11.12.169:3001"
//let urlCarQuery = "http://10.11.12.245:3001"
//let urlWebsocket = "ws://10.11.12.14:3001/"
let urlWebsocket = "ws://10.11.12.169:3006/"
let urlInspections = "http://10.11.12.169:3011/inspections"
let urlLicensePlate = "http://localhost:3000/license_plate"

enum urls {
    case cars
    case query
    case inspections
    case licensePlate
}

func getURL(_ whichURL: urls) -> URL {
    switch whichURL {
        case .cars:
            return URL(string: urlCars)!
        case .query:
            return URL(string: urlWebsocket)!
        case .inspections:
            return URL(string: urlInspections)!
        case .licensePlate:
            return URL(string: urlLicensePlate)!
    }
}

func getURLasString(_ whichURL: urls) -> String {
    switch whichURL {
        case .cars:
            return urlCars
        case .query:
            return urlCarQuery
        case .inspections:
            return urlInspections
        case .licensePlate:
            return urlLicensePlate
    }
}
