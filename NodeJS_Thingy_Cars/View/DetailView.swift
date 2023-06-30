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
    @EnvironmentObject var sharedViewData: SharedViewData
    
    @State private var selectedCar: Car
    @State private var region: MKCoordinateRegion
        
    init(selectedCar: Car, region: MKCoordinateRegion) {
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
            
            Section {
                Map(
                    coordinateRegion: $region,
                    interactionModes: MapInteractionModes.all,
                    annotationItems: [selectedCar]
                ) {
                    MapMarker(coordinate: $0.getLocation().center)
                }
                .frame(height: 200)
                .cornerRadius(15)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .navigationTitle(selectedCar.getLP())
#if os(iOS)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing, content: {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .isHidden(!sharedViewData.isLoading)
                
                Link(destination:
                    URL(string:"https://magyarorszag.hu/jszp_szuf")!
                ) {
                    Image(systemName: "link")
                }
                
                editButton
                    .disabled(sharedViewData.isLoading)
            })
        }
#endif
        .sheet(isPresented: $sharedViewData.isEditCarPresented, onDismiss: {
            Task {
                sharedViewData.isLoading = true
                let (safeCar, safeCarError) = await loadCar(license_plate: sharedViewData.existingCar.license_plate)
                if let safeCar {
                    sharedViewData.existingCar = safeCar[0]
                    selectedCar = sharedViewData.existingCar
                }
                
                let (safeBrands, safeBrandError) = await loadBrands()
                if let safeBrands {
                    sharedViewData.brands = safeBrands
                }
                
                if let safeCarError {
                    sharedViewData.error = safeCarError
                    sharedViewData.showAlert = true
                }
                if let safeBrandError {
                    sharedViewData.error = safeBrandError
                    sharedViewData.showAlert = true
                }
                
                sharedViewData.isLoading = false
            }
        }) {
            NewCar(isUpload: false)
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

struct View2_Previews: PreviewProvider {
    static var previews: some View {
        CarDetails(selectedCar: Car(license_plate: "AAA111", brand_id: 3, brand: "BMW", model: "M5", codename: "E60", year: 2008, comment: "Heee", is_new: 0, latitude: 39, longitude: -122), region: MKCoordinateRegion(
            center:  CLLocationCoordinate2D(
              latitude: 37.789467,
              longitude: -122.416772
            ),
            span: MKCoordinateSpan(
              latitudeDelta: 0.01,
              longitudeDelta: 0.01
           )
        ))
        .environmentObject(SharedViewData())
    }
}
