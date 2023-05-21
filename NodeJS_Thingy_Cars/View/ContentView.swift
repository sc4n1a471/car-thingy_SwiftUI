//
//  ContentView.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 6/30/22.
//

import SwiftUI
import MapKit

class SharedViewData: ObservableObject {    
    @Published var results = ReturnCar()
    @Published var brands = [Brand]()
    
    @Published var showAlert = false
    @Published var isLoading = false
    @Published var areCarsLoaded = false
    @Published var isNewCarPresented = false
    @Published var isEditCarPresented = false
    
    @Published var newCar = Car(license_plate: "", brand_id: 1, brand: "", model: "", codename: "", year: 0, comment: "", is_new: 1, latitude: 37.332914, longitude: -122.005202)
    @Published var existingCar = Car(license_plate: "", brand_id: 1, brand: "", model: "", codename: "", year: 0, comment: "", is_new: 1, latitude: 10.332914, longitude: -122.005202)
    
    @Published var region = MKCoordinateRegion(
        center:  CLLocationCoordinate2D(
          latitude: 37.789467,
          longitude: -122.416772
        ),
        span: MKCoordinateSpan(
          latitudeDelta: 0.01,
          longitudeDelta: 0.01
       )
    )
    @Published var selectedBrand = 1
    @Published var is_new: Bool = true
    var oldLicensePlate = ""
    var yearAsString = ""
}

struct ContentView: View {
    @StateObject var sharedViewData = SharedViewData()

    @State private var searchCar = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(searchCars, id: \.license_plate) { result in
                    NavigationLink {
                        CarDetails(selectedCar: result, region: result.getLocation())
                    } label: {
                        VStack(alignment: .leading) {
                            Text(result.getLP())
                                .font(.headline)
                            HStack {
                                if (result.is_new == 1) {
                                    Text("New car!")
                                } else {
                                    Text(result.model)
                                    if result.hasCodename {
                                        Text(result.codename)
                                    }
                                }
                            }
                        }
                    }
                }
                .onDelete { IndexSet in
                    Task {
                        sharedViewData.results = try await deleteData(at: IndexSet, cars: sharedViewData.results.cars)
                        
                        if (sharedViewData.results.error != "DEFAULT_VALUE") {
                            print("error delete")
                            sharedViewData.showAlert = true
                        }
                    }
                }
            }
            .task {
                if (!sharedViewData.areCarsLoaded) {
                    await loadViewData()
                }
            }
            .navigationTitle("Cars")
            
            #if os(iOS)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading, content: {
                    
                    Link(destination:
                        URL(string:"https://magyarorszag.hu/jszp_szuf")!
                    ) {
                        Image(systemName: "link")
                    }
                    
                    Button(action: {
                        Task {
                            await loadViewData()
                        }
                    }, label: {
                        Image(systemName: "arrow.clockwise")
                    })
                })
                
                ToolbarItemGroup(placement: .navigationBarTrailing, content: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .isHidden(!sharedViewData.isLoading)
                    
                    plusButton.disabled(sharedViewData.isLoading)
                })
            }
            #endif
            
            .refreshable {
                await loadViewData()
            }
            .searchable(text: $searchCar)
        }
        .alert(sharedViewData.results.error, isPresented: $sharedViewData.showAlert, actions: {
            Button("Got it") {
                print("alert confirmed")
            }
        })
        .sheet(isPresented: $sharedViewData.isNewCarPresented, onDismiss: {
            Task {
                await loadViewData()
                sharedViewData.newCar = Car(license_plate: "", brand_id: 1, brand: "", model: "", codename: "", year: 0, comment: "", is_new: 1, latitude: 37.332914, longitude: -122.005202)
                sharedViewData.selectedBrand = 1
            }
        }) {
            NewCar(isUpload: true)
                .environmentObject(sharedViewData)
        }
        .environmentObject(sharedViewData)
    }
    
    var plusButton: some View {
        Button (action: {
            sharedViewData.isNewCarPresented.toggle()
        }, label: {
            Image(systemName: "plus")
        })
    }
    
    var searchCars: [Car] {
        if searchCar.isEmpty {
            return sharedViewData.results.cars
        } else {
            if self.searchCar.localizedStandardContains("new") {
                return sharedViewData.results.cars.filter {
                    $0.is_new == 1
                }
            }
            return sharedViewData.results.cars.filter {
                $0.license_plate.contains(self.searchCar.uppercased()) ||
                $0.brand.localizedStandardContains(self.searchCar) ||
                $0.model.localizedStandardContains(self.searchCar)
            }
        }
    }
    
    func loadViewData() async {
        sharedViewData.isLoading = true
        sharedViewData.results = await loadData()
        sharedViewData.brands = await loadBrands()
        sharedViewData.isLoading = false
        if (sharedViewData.results.error != "DEFAULT_VALUE") {
            sharedViewData.showAlert = true
        }
        sharedViewData.areCarsLoaded = true
    }
}

extension View {
    @ViewBuilder func isHidden(_ isHidden: Bool) -> some View {
        if isHidden {
            self.hidden()
        } else {
            self
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
