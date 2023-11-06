//
//  LocationManager.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 9/11/22.
//

//import UIKit
import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    
    @Published var region = MKCoordinateRegion()

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.stopUpdatingLocation()      // in theory, stops immediately after it starts updating location to prevent location updates more than once
    }

//    func requestLocation() {
//        manager.requestLocation()
//    }

//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        region.center.latitude = locations.first!.coordinate.latitude
//        region.center.longitude = locations.first!.coordinate.longitude
//        print(locations)
//    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            locations.last.map {
                region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                )
            }
        }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
}
