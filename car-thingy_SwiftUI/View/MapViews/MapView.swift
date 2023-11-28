    //
    //  MapView.swift
    //  car-thingy_SwiftUI
    //
    //  Created by Martin Terhes on 11/11/23.
    //

import SwiftUI
import MapKit

struct MapView: View {
    @Environment(SharedViewData.self) private var sharedViewData
    @State private var viewModel = ViewModel()
    @State private var selectedLicensePlate: String?
    
    var body: some View {
        Map(initialPosition: .region(viewModel.position), selection: $selectedLicensePlate) {
            ForEach(sharedViewData.cars, id: \.license_plate.license_plate) { coordinateObject in
                Marker(coordinateObject.license_plate.license_plate, coordinate: CLLocationCoordinate2D(latitude: coordinateObject.coordinates.latitude, longitude: coordinateObject.coordinates.longitude))
                    .tag(coordinateObject.license_plate.license_plate)
                    .tint(coordinateObject.specs.brand != String() ? .blue : .red)
            }
        }.onAppear(perform: {
            viewModel.initViewModel(sharedViewData)
            Task {
                await viewModel.loadMarkers()
            }
        })
        .sheet(isPresented: $viewModel.infoSheet, onDismiss: {
            withAnimation(.snappy) {
                selectedLicensePlate = nil
            }
        }, content: {
            MapDetailView(selectedLicensePlate: $selectedLicensePlate)
                .presentationDetents([.medium, .large])
                .presentationBackground(.ultraThickMaterial)
        })
        .onChange(of: selectedLicensePlate) {
            if let selectedLicensePlate {
                viewModel.infoSheet = true
            }
            Task {
                await viewModel.loadMarkers()
            }
        }
		.navigationTitle("Map")
    }
}

#Preview {
    MapView()
        .environment(SharedViewData())
}
