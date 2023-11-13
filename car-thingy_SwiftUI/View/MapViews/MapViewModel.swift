//
//  MapViewModel.swift
//  car-thingy_SwiftUI
//
//  Created by Martin Terhes on 11/11/23.
//

import Foundation
import MapKit

extension MapView {
    @Observable class ViewModel {
        var position = MKCoordinateRegion(
            center:  CLLocationCoordinate2D(
                latitude: 46.252273,
                longitude: 20.152104
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.05,
                longitudeDelta: 0.05
            )
        )
        
        var coordinates: [Coordinates] = [Coordinates()]
        var infoSheet: Bool = false
        
        func loadCoordinatesToView() async {
            let (safeData, safeError) = await loadCoordinates()
            
            if let safeData {
                coordinates = safeData
            }
            
            if let safeError {
                // TODO: Show alert if error
                print(safeError)
            }
        }
    }
}
