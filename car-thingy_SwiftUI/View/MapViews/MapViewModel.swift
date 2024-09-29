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
        
		var knownCar: Bool = false
        var infoSheet: Bool = false
        var sharedViewData: SharedViewData?
        
        func initViewModel(_ sharedViewData: SharedViewData) {
            self.sharedViewData = sharedViewData
        }
        
        func loadMarkers() async {
            let (cars, error) = await loadCars()
            
            if let cars {
                sharedViewData?.cars = cars
            }
            
            if let error {
				sharedViewData?.showAlert(.mapView, error)
            }
        }
    }
}
