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

/// https://www.createwithswift.com/updating-the-users-location-with-core-location-and-swift-concurrency-in-swiftui/

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
	
	var region = MKCoordinateRegion()
	var lastLocation: CLLocation = CLLocation(latitude: 40.748443, longitude: -73.985650)
	var message: String?
    
    //MARK: Continuation Object for the User Location
    private var continuation: CheckedContinuation<CLLocation, Error>?
    
    // Error messages associated with the location manager
    enum LocationManagerError: String, Error {
        case replaceContinuation = "Continuation replaced."
        case locationNotFound = "No location found."
    }

    override init() {
        super.init()
        manager.delegate = self
//        manager.requestWhenInUseAuthorization()
//		manager.startUpdatingLocation()
    }
    
    //MARK: Asynchronously request the current location
    var currentLocation: CLLocation {
        get async throws {
            print("currectLocation start")
            // Check if there is a continuation being worked on
            if self.continuation != nil {
                // If so, resumes it throwing an error
                self.continuation?.resume(throwing: LocationManagerError.replaceContinuation)
                // And deletes it, so a new one can be created
                self.continuation = nil
            }
        
            return try await withCheckedThrowingContinuation { continuation in
                // 1. Set up the continuation object
                self.continuation = continuation
                // 2. Triggers the update of the current location
                self.manager.requestLocation()
            }
        }
    }
    
    //MARK: Request Authorization to access the User Location
    func checkAuthorization() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])")
        // 4. If there is a location available
        if let safeLastLocation = locations.last {
            DDLogVerbose("locationMaanger got location: \(safeLastLocation)")
            // 5. Resumes the continuation object with the user location as result
            continuation?.resume(returning: safeLastLocation)
            // Resets the continuation object
            continuation = nil
            locations.last.map {
                region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                )
            }
            lastLocation = safeLastLocation
        } else {
            // If there is no location, resumes the continuation throwing and error to avoid a continuation leak
            continuation?.resume(throwing: LocationManagerError.locationNotFound)
            DDLogError("locationManager no location")
        }
	}
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		DDLogError("locationManager error: \(error.localizedDescription)")
		message = error.localizedDescription
        // 6. If not possible to retrieve a location, resumes with an error
        continuation?.resume(throwing: error)
        // Resets the continuation object
        continuation = nil
    }
}

