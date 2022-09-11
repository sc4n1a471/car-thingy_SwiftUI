//
//  CarLocation.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 9/11/22.
//

import Foundation
import MapKit

struct CarLocation: Codable {
    var lo: Double
    var la: Double
    
    func getLocation() -> MKCoordinateRegion {
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: self.la, longitude: self.lo),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    }
}
