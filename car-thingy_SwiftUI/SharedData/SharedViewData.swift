//
//  SharedViewData.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/8/23.
//

import Foundation
import MapKit

class SharedViewData: ObservableObject {
    @Published var cars = [Car]()
    @Published var error: String?
    
    @Published var showAlert = false
    @Published var isLoading = false
    @Published var isNewCarPresented = false
    @Published var isEditCarPresented = false
    
    @Published var newCar: Car = Car()
    @Published var existingCar: Car = Car()
    
    @Published var region = MKCoordinateRegion(
        center:  CLLocationCoordinate2D(
          latitude: 37.789467,
          longitude: -122.416772
        ),
        span: MKCoordinateSpan(
          latitudeDelta: 0.01,
          longitudeDelta: 0.01
       )
    )
    @Published var is_new: Bool = true
    var oldLicensePlate = ""
    var yearAsString = ""
    
    init() {}
    
    func clearNewCar() {
        self.newCar = Car()
    }
    
    func clearExistingCar() {
        self.existingCar = Car()
    }
}
