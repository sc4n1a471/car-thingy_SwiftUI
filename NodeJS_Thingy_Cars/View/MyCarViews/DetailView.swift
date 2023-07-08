//
//  View2.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/3/22.
//

import SwiftUI
import CoreLocation
import MapKit

struct DetailView: View {
    @EnvironmentObject var sharedViewData: SharedViewData
    @EnvironmentObject var querySharedData: QuerySharedData
    
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
                    SpecView(header: "Brand", content: selectedCar.brand)
                }
            }
            if selectedCar.hasModel {
                Section {
                    SpecView(header: "Model", content: selectedCar.model)
                }
            }
            if selectedCar.hasCodename {
                Section {
                    SpecView(header: "Codename", content: selectedCar.codename)
                }
            }
            if selectedCar.hasYear {
                Section {
                    SpecView(header: "Year", content: String(selectedCar.year))
                }
            }
            if selectedCar.hasComment {
                Section {
                    SpecView(header: "Comment", content: selectedCar.comment)
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
                .cornerRadius(10)
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
                    .isHidden(!querySharedData.isLoading)
                    .isHidden(sharedViewData.isLoading)
                
                queryButton
                    .disabled(querySharedData.isLoading)
                
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
                    MyCarsView().haptic(type: .error)
                }
                if let safeBrandError {
                    sharedViewData.error = safeBrandError
                    sharedViewData.showAlert = true
                    MyCarsView().haptic(type: .error)
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
            print(querySharedData)
        }
    }
    
    var editButton: some View {
        Button (action: {
            sharedViewData.isEditCarPresented.toggle()
        }, label: {
            Image(systemName: "pencil")
        })
    }
    
    var queryButton: some View {
        Button(action: {
            Task {
                await queryCarButton(requestedCar: selectedCar.license_plate)
            }
        }, label: {
            Image(systemName: "magnifyingglass")
        })
    }
    
    func queryCarButton(requestedCar: String) async {
        querySharedData.isLoading.toggle()
        
        let (safeCar, safeCarError) = await queryCar(license_plate: requestedCar)
        if let safeCar {
            querySharedData.queriedCar = safeCar
            querySharedData.isQueriedCarLoaded.toggle()
            print(querySharedData.isQueriedCarLoaded)
        }
        
        if let safeCarError {
            MyCarsView().haptic(type: .error)
            querySharedData.error = safeCarError
            querySharedData.showAlert = true
        }
        querySharedData.isLoading.toggle()
    }
}

struct View2_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(selectedCar: Car(license_plate: "AAA111", brand_id: 3, brand: "BMW", model: "M5", codename: "E60", year: 2008, comment: "Heee", is_new: 0, latitude: 39, longitude: -122), region: MKCoordinateRegion(
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
        .environmentObject(QuerySharedData())
    }
}
