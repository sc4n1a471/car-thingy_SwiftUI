//
//  SharedViewData.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/8/23.
//

import Foundation
import MapKit
import CocoaLumberjackSwift

@Observable class SharedViewData {
    var cars = [Car]()
    var error: String?
    
	var showAlertMyCars = false
	var showAlertNewCar = false
	var showAlertDetailView = false
	var showAlertQueryView = false
	var showAlertMapView = false
	var showMiniQueryView = false

    var isLoading = false
    var isNewCarPresented = false
    var isEditCarPresented = false
    
    var newCar: Car = Car()
    var existingCar: Car = Car()
	var returnNewCar: Car = Car()
	
	var websocket: Websocket = Websocket()
	    
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
	
	enum HapticType: String {
		case notification
		case standard
		case error
	}
	
	enum AlertLocations: String {
		case myCars
		case newCar
		case detailView
		case queryView
		case mapView
	}
    
    init() {}
	
	func haptic(type: HapticType = .standard, intensity: CGFloat = 0.5) {
		print("Haptic")
		switch type {
			case .standard:
				let impact = UIImpactFeedbackGenerator()
				impact.prepare()
				impact.impactOccurred(intensity: intensity)
			case .notification:
				let generator = UINotificationFeedbackGenerator()
				generator.prepare()
				generator.notificationOccurred(.success)
			case .error:
				let generator = UINotificationFeedbackGenerator()
				generator.prepare()
				generator.notificationOccurred(.error)
		}
	}
    
    func clearNewCar() {
        self.newCar = Car()
    }
    
    func clearExistingCar() {
        self.existingCar = Car()
    }
    
	func showAlert(_ alertLocation: AlertLocations, _ errorMsg: String) {
		switch alertLocation {
			case .myCars:
				showAlertMyCars = true
			case .newCar:
				showAlertNewCar = true
			case .detailView:
				showAlertDetailView = true
			case .queryView:
				showAlertQueryView = true
			case .mapView:
				showAlertMapView = true
		}
        self.isLoading = false
        self.error = errorMsg
        DDLogError(errorMsg)
		self.haptic(type: .error)
    }
	
	func loadViewData(_ refresh: Bool = false) async {
		self.isLoading = true
		let (safeCars, safeCarError) = await loadCars(refresh)
		if let safeCars {
			self.cars = safeCars
		}
		
		if let safeCarError {
			self.showAlert(.myCars, safeCarError)
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
