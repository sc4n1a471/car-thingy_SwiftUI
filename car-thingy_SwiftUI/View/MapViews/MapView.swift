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
		// required because can't use environment as binding
		@Bindable var sharedViewDataBindable = sharedViewData
		
        Map(initialPosition: .region(viewModel.position), selection: $selectedLicensePlate) {
            ForEach(sharedViewData.cars, id: \.licensePlate) { coordinateObject in
                Marker(coordinateObject.licensePlate, coordinate: CLLocationCoordinate2D(latitude: coordinateObject.latitude, longitude: coordinateObject.longitude))
                    .tag(coordinateObject.licensePlate)
                    .tint(coordinateObject.brand != nil ? .blue : .red)
            }
        }.onAppear(perform: {
            viewModel.initViewModel(sharedViewData)
            Task {
                await viewModel.loadMarkers()
            }
        })
		.alert(sharedViewData.error ?? "sharedViewData.error is a nil??", isPresented: $sharedViewDataBindable.showAlertMapView) {
			Button("Got it") {
				print("alert confirmed")
			}
		}
        .sheet(isPresented: $viewModel.infoSheet, onDismiss: {
            withAnimation(.snappy) {
                selectedLicensePlate = nil
            }
        }, content: {
            MapDetailView(selectedLicensePlate: $selectedLicensePlate)
				.presentationDetents(
					viewModel.knownCar ? [.medium, .large] : [.fraction(0.35), .medium, .large]
				)
                .presentationBackground(.ultraThickMaterial)
        })
        .onChange(of: selectedLicensePlate) {
            if let selectedLicensePlate {
                viewModel.infoSheet = true
				viewModel.knownCar = sharedViewData.cars.first(where: { $0.licensePlate == selectedLicensePlate })?.brand != nil
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
