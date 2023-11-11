//
//  MapView.swift
//  car-thingy_SwiftUI
//
//  Created by Martin Terhes on 11/11/23.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var viewModel = ViewModel()
    var body: some View {
        Map(initialPosition: .region(viewModel.region)) {
            ForEach(viewModel.coordinates, id: \.license_plate) { coordinateObject in
                Marker(coordinateObject.license_plate, coordinate: CLLocationCoordinate2D(latitude: coordinateObject.latitude, longitude: coordinateObject.longitude))
            }
        }.onAppear(perform: {
                Task {
                    let (safeData, safeError) = await loadCoordinates()
                    
                    if let safeData {
                        viewModel.coordinates = safeData
                    }
                    
                    if let safeError {
                        print(safeError)
                    }
                }
            })
    }
}

#Preview {
    MapView()
}
