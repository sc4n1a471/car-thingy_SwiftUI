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
    @State private var selectedLicensePlate: String?

    var body: some View {
        Map(initialPosition: .region(viewModel.position), selection: $selectedLicensePlate) {
            ForEach(viewModel.coordinates, id: \.license_plate) { coordinateObject in
                Marker(coordinateObject.license_plate, coordinate: CLLocationCoordinate2D(latitude: coordinateObject.latitude, longitude: coordinateObject.longitude))
                    .tag(coordinateObject.license_plate)
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
        .sheet(isPresented: $viewModel.infoSheet, content: {
            MapDetailView(selectedLicensePlate: selectedLicensePlate!)
                .presentationDetents([.medium, .large])
        })
        .onChange(of: selectedLicensePlate) {
            if let selectedLicensePlate {
                viewModel.infoSheet = true
            }
        }
    }
}

#Preview {
    MapView()
}
