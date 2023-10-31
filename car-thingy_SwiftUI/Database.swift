//
//  Database.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/3/22.
//

import Foundation

let urlCars = "http://10.11.12.169/cars"
//let urlCars = "http://10.11.12.109:3000/cars"
let urlBrands = "http://10.11.12.169/carBrands"
//let urlBrands = "http://10.11.12.109:3000/carBrands"
let urlCarQuery = "http://10.11.12.169:3001"
//let urlCarQuery = "http://10.11.12.245:3001"
//let urlWebsocket = "ws://10.11.12.14:3001/"
let urlWebsocket = "ws://10.11.12.169:3006/"
let urlInspections = "http://10.11.12.169:3011/inspections"

func getURL(whichUrl: String) -> URL {
    if (whichUrl == "cars") {
        return URL(string: urlCars)!
    } else if (whichUrl == "brands") {
        return URL(string: urlBrands)!
    } else if (whichUrl == "carQuery") {
        return URL(string: urlCarQuery)!
    } else if (whichUrl == "carWebsocket") {
        return URL(string: urlWebsocket)!
    } else if (whichUrl == "carInspections") {
        return URL(string: urlInspections)!
    }
    return URL(string: "http://google.com")!
}

func getURLasString(whichUrl: String) -> String {
    if (whichUrl == "cars") {
        return urlCars
    } else if (whichUrl == "brands") {
        return urlBrands
    } else if (whichUrl == "carQuery") {
        return urlCarQuery
    } else if (whichUrl == "carWebsocket") {
        return urlWebsocket
    } else if (whichUrl == "carInspections") {
        return urlInspections
    }
    return "http://duckduckgo.com"
    
}
