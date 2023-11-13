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
                    await viewModel.loadCoordinatesToView()
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
                await viewModel.loadCoordinatesToView()
            }
        }
    }
}

#Preview {
    MapView()
}
