//
//  LocationManager.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 9/11/22.
//

//import UIKit
import CoreLocation
import MapKit
import os
import CocoaLumberjackSwift

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
	
	var region = MKCoordinateRegion()
	var lastLocation: CLLocation = CLLocation(latitude: 40.748443, longitude: -73.985650)
	var message: String?

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
		manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		var location: CLLocation
		if let safeLocation = locations.last {
			location = safeLocation
			
			lastLocation = location
			DDLogDebug("locationManager - location: \(self.lastLocation)")
			
			locations.last.map {
				region = MKCoordinateRegion(
					center: CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude),
					span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
				)
			}
			
			if location.coordinate.latitude != 40.748443 && location.coordinate.longitude != -73.985650 {
				DDLogDebug("Location data is no longer Empire State Building, stopping updating location")
				manager.stopUpdatingLocation()
			}
		} else {
			location = CLLocation(latitude: 40.748443, longitude: -73.985650)
			DDLogDebug("locations.last was nil????")
			message = "locaitions.last was nil????"
		}
	}
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		DDLogError("locationManager error: \(error.localizedDescription)")
		message = error.localizedDescription
    }
}
