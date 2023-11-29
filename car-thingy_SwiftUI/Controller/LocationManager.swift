//
//  LocationManager.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 9/11/22.
//

//import UIKit
import CoreLocation
import MapKit

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
	
	var region = MKCoordinateRegion()
	var lastLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
		manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else { return }
		lastLocation = location
		print("locationManager - location: \(lastLocation)")
		
		locations.last.map {
			region = MKCoordinateRegion(
				center: CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude),
				span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
			)
		}
		
		if location.coordinate.latitude != 0 && location.coordinate.longitude != 0 {
			manager.stopUpdatingLocation()
		}
	}
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
}
