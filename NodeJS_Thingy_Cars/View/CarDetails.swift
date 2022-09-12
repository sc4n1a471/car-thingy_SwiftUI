//
//  View2.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/3/22.
//

import SwiftUI
import CoreLocation
import MapKit

struct CarDetails: View {
    @State var car: Car
    @State var isEditCarPresented = false
    @State var isNew: Bool?
    @State var brands: [Brand]
    @State var isLoading = false
    
    @State var region = MKCoordinateRegion(
        center:  CLLocationCoordinate2D(
          latitude: 37.789467,
          longitude: -122.416772
        ),
        span: MKCoordinateSpan(
          latitudeDelta: 0.1,
          longitudeDelta: 0.1
       )
    )
//    @State var isTracking: MapUserTrackingMode = .none
//    @StateObject var locationManager = LocationManager()
    
    var body: some View {
        List {
            if car.hasBrand {
                Section {
                    Text(String(car.brand))
                } header: {
                    Text("Brand")
                }
            }
            if car.hasModel {
                Section {
                    Text(String(car.model))
                } header: {
                    Text("Model")
                }
            }
            if car.hasCodename {
                Section {
                    Text(String(car.codename))
                } header: {
                    Text("Codename")
                }
            }
            if car.hasYear {
                Section {
                    Text(String(car.year))
                } header: {
                    Text("Year")
                }
            }
            if car.hasComment {
                Section {
                    Text(car.comment)
                } header: {
                    Text("Comment")
                }
            }
            Map(
                coordinateRegion: $region,
                interactionModes: MapInteractionModes.all,
                annotationItems: [car]
            ) {
                MapMarker(coordinate: $0.getLocation().center)
            }
                .frame(height: 200)
        }
        .task {
            isLoading = true
            car = await loadCar(license_plate: car.license_plate).cars[0]
            isLoading = false
        }
        .navigationTitle(car.getLP())
#if os(iOS)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing, content: {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .isHidden(!isLoading)
                
                editButton
                    .disabled(isLoading)
            })
        }
#endif
        .sheet(isPresented: $isEditCarPresented, onDismiss: {
            Task {
                isLoading = true
                car = await loadCar(license_plate: car.license_plate).cars[0]
                brands = await loadBrands()
                isLoading = false
            }
        }) {
            NewCar(isPresented: isEditCarPresented, isUpdate: true, isUpload: false, year: String(car.year), is_new: car.isNew(), ezLenniCar: self.$car, brands: brands, selectedBrand: car.brand_id, oldLicensePlate: car.license_plate, region: car.getLocation())
        }
    }
    
    var editButton: some View {
        Button (action: {
            isEditCarPresented.toggle()
        }, label: {
            Image(systemName: "pencil")
        })
    }
}

struct View2_Previews: PreviewProvider {
    static var previews: some View {
        CarDetails(car: Car(license_plate: "", brand_id: 1, brand: "", model: "", codename: "", year: 0, comment: "", is_new: 1, latitude: 46.229014679521015, longitude: 20.186523048482677), brands: [Brand(brand_id: 1, brand: "he")])
    }
}
