//
//  QuerySharedData.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/8/23.
//

import Foundation

class QuerySharedData: ObservableObject {
    @Published var requestedLicensePlate: String = ""
    @Published var queriedCar: CarQuery?
    @Published var error: String?
    @Published var showAlert = false
    @Published var isQueriedCarLoaded = false
    @Published var isLoading = false
}
