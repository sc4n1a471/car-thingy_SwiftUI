//
//  CarLocation.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 9/11/22.
//

import Foundation
import MapKit

struct CarLocation: Codable {
    var latitude: Double
    var longitude: Double
    
    func getLocation() -> MKCoordinateRegion {
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    }
}
