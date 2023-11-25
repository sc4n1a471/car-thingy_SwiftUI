//
//  SharedViewData.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/8/23.
//

import Foundation
import MapKit

@Observable class SharedViewData {
    var cars = [Car]()
    var error: String?
    
    var showAlert = false
    var isLoading = false
    var isNewCarPresented = false
    var isEditCarPresented = false
    
    var newCar: Car = Car()
    var existingCar: Car = Car()
	var returnNewCar: Car = Car()
    
    var region = MKCoordinateRegion(
        center:  CLLocationCoordinate2D(
          latitude: 37.789467,
          longitude: -122.416772
        ),
        span: MKCoordinateSpan(
          latitudeDelta: 0.01,
          longitudeDelta: 0.01
       )
    )
    var is_new: Bool = true
    private var oldLicensePlate = ""
    private var yearAsString = ""
    
    init() {}
    
    func clearNewCar() {
        self.newCar = Car()
    }
    
    func clearExistingCar() {
        self.existingCar = Car()
    }
    
    func showAlert(errorMsg: String) {
        self.isLoading = false
        self.showAlert = true
        self.error = errorMsg
        print(errorMsg)
        MyCarsView().haptic(type: .error)
    }
	
	func loadViewData(_ refresh: Bool = false) async {
		self.isLoading = true
		let (safeCars, safeCarError) = await loadCars(refresh)
		if let safeCars {
			self.cars = safeCars
		}
		
		if let safeCarError {
			self.showAlert(errorMsg: safeCarError)
		}
		
		self.isLoading = false
	}
	
	func parseDate(_ unparsedData: String) -> Date {
		let calendar = Calendar.autoupdatingCurrent
		if unparsedData.contains("-") {
			let dateTimeSeparated = unparsedData.split(separator: "T")
			let dateSeparated = dateTimeSeparated[0].split(separator: "-")
			return calendar.date(from: DateComponents(year: Int(dateSeparated[0]), month: Int(dateSeparated[1]), day: Int(dateSeparated[2])))!
		} else if unparsedData.contains(".") {
			let dateSeparated = unparsedData.split(separator: ".")
			return calendar.date(from: DateComponents(year: Int(dateSeparated[0]), month: Int(dateSeparated[1]), day: Int(dateSeparated[2])))!
		}
		return Date.now
	}
}
