//
//  View2.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/3/22.
//

import SwiftUI
import CoreLocation
import MapKit

//class SharedCarDetails: ObservableObject {
//    @Published var car = Car(license_plate: "", brand_id: 1, brand: "", model: "", codename: "", year: 0, comment: "", is_new: 1, latitude: 37.332914, longitude: -122.005202)
//    @Published var isEditCarPresented = false
//    @Published var region = MKCoordinateRegion(
//        center:  CLLocationCoordinate2D(
//          latitude: 37.789467,
//          longitude: -122.416772
//        ),
//        span: MKCoordinateSpan(
//          latitudeDelta: 0.01,
//          longitudeDelta: 0.01
//       )
//    )
//    @Published var selectedBrand = 1
//}

struct CarDetails: View {
    @EnvironmentObject var sharedViewData: SharedViewData
//    @StateObject var sharedCarDetails: SharedCarDetails
    
    @State private var selectedCar: Car
//    @State private var isEditCarPresented = false
//    @State private var isNew: Bool?
//    @State var brands: [Brand]
//    @State var isLoading = false
    
    @State var region: MKCoordinateRegion
    
//    @State var isTracking: MapUserTrackingMode = .none
//    @StateObject var locationManager = LocationManager()
    
    init(selectedCar: Car, region: MKCoordinateRegion) {
////        self.sharedViewData = sharedViewData
////        self.sharedCarDetails = sharedCarDetails
////        self.isEditCarPresented = isEditCarPresented
////        self.isNew = isNew
////        self.region = region
        self.selectedCar = selectedCar
        self.region = region
    }
    
    var body: some View {
        List {
            if selectedCar.hasBrand {
                Section {
                    Text(String(selectedCar.brand))
                } header: {
                    Text("Brand")
                }
            }
            if selectedCar.hasModel {
                Section {
                    Text(String(selectedCar.model))
                } header: {
                    Text("Model")
                }
            }
            if selectedCar.hasCodename {
                Section {
                    Text(String(selectedCar.codename))
                } header: {
                    Text("Codename")
                }
            }
            if selectedCar.hasYear {
                Section {
                    Text(String(selectedCar.year))
                } header: {
                    Text("Year")
                }
            }
            if selectedCar.hasComment {
                Section {
                    Text(selectedCar.comment)
                } header: {
                    Text("Comment")
                }
            }
            Map(
                coordinateRegion: $sharedViewData.region,
                interactionModes: MapInteractionModes.all,
                annotationItems: [selectedCar]
            ) {
                MapMarker(coordinate: $0.getLocation().center)
            }
                .frame(height: 200)
        }
        .task {
            sharedViewData.isLoading = true
            sharedViewData.existingCar = await loadCar(license_plate: sharedViewData.existingCar.license_plate).cars[0]
            sharedViewData.isLoading = false
        }
        .navigationTitle(selectedCar.getLP())
#if os(iOS)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing, content: {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .isHidden(!sharedViewData.isLoading)
                
                editButton
                    .disabled(sharedViewData.isLoading)
            })
        }
#endif
        .sheet(isPresented: $sharedViewData.isEditCarPresented, onDismiss: {
            Task {
                sharedViewData.isLoading = true
                sharedViewData.existingCar = await loadCar(license_plate: sharedViewData.existingCar.license_plate).cars[0]
                sharedViewData.brands = await loadBrands()
                sharedViewData.isLoading = false
            }
        }) {
            NewCar(isUpdate: State(initialValue: true), isUpload: State(initialValue: false), year: State(initialValue: String(sharedViewData.existingCar.year)), oldLicensePlate: State(initialValue: sharedViewData.existingCar.license_plate))
        }
        .onAppear() {
            sharedViewData.existingCar = selectedCar
            sharedViewData.region = region
            sharedViewData.existingCar.isNew() ? (sharedViewData.is_new = true) : (sharedViewData.is_new = false)
            sharedViewData.selectedBrand = sharedViewData.existingCar.brand_id
        }
    }
    
    var editButton: some View {
        Button (action: {
            sharedViewData.isEditCarPresented.toggle()
        }, label: {
            Image(systemName: "pencil")
        })
    }
}

//struct View2_Previews: PreviewProvider {
//    static var previews: some View {
//
//    }
//}
