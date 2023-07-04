//
//  ContentView.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 6/30/22.
//

import SwiftUI
import MapKit

class SharedViewData: ObservableObject {
    @Published var brands = [Brand]()
    @Published var cars = [Car]()
    @Published var error: String?
    
    @Published var showAlert = false
    @Published var isLoading = false
    @Published var isNewCarPresented = false
    @Published var isEditCarPresented = false
    
    @Published var newCar = ContentView().createEmptyCar()
    @Published var existingCar = ContentView().createEmptyCar()
    
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

enum HapticType: String {
    case notification
    case standard
    case error
}

struct ContentView: View {
    @StateObject var sharedViewData = SharedViewData()

    @State private var searchCar = ""
    
    var body: some View {
        NavigationView {
            
            List {
                ForEach(searchCars, id: \.license_plate) { result in
                    NavigationLink {
                        DetailView(selectedCar: result, region: result.getLocation())
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
                        let (unsafeCars, unsafeError) = try await deleteData(at: IndexSet, cars: sharedViewData.cars)
                        
                        if let safeCars = unsafeCars {
                            sharedViewData.cars = safeCars
                            haptic()
                        }
                        
                        if let safeError = unsafeError {
                            sharedViewData.error = safeError
                            sharedViewData.showAlert = true
                            haptic(type: .error)
                        }
                    }
                }
            }
            .task {
                await loadViewData()
            }
            .navigationTitle("My Cars")
            
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
                            await loadViewData(true)
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
                await loadViewData(true)
            }
            .searchable(text: $searchCar)
        }
        .alert(sharedViewData.error ?? "sharedViewData.error is a nil??", isPresented: $sharedViewData.showAlert) {
            Button("Got it") {
                print("alert confirmed")
            }
        }
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
            return sharedViewData.cars
        } else {
            if self.searchCar.localizedStandardContains("new") {
                return sharedViewData.cars.filter {
                    $0.is_new == 1
                }
            }
            return sharedViewData.cars.filter {
                $0.license_plate.contains(self.searchCar.uppercased()) ||
                $0.brand.localizedStandardContains(self.searchCar) ||
                $0.model.localizedStandardContains(self.searchCar)
            }
        }
    }
    
    func loadViewData(_ refresh: Bool = false) async {
        sharedViewData.isLoading = true
        let (safeCars, safeCarError) = await loadData(refresh)
        if let safeCars {
            withAnimation {
                sharedViewData.cars = safeCars
            }
        }
        let (safeBrands, safeBrandError) = await loadBrands()
        if let safeBrands {
            sharedViewData.brands = safeBrands
        }
        
        if let safeCarError {
            sharedViewData.error = safeCarError
            sharedViewData.showAlert = true
            haptic(type: .error)
        }
        if let safeBrandError {
            sharedViewData.error = safeBrandError
            sharedViewData.showAlert = true
            haptic(type: .error)
        }
        
        sharedViewData.isLoading = false
    }
    
    func haptic(type: HapticType = .standard, intensity: CGFloat = 0.5) {
        print("Haptic")
        switch type {
        case .standard:
            let impact = UIImpactFeedbackGenerator()
            impact.prepare()
            impact.impactOccurred(intensity: intensity)
        case .notification:
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.success)
        case .error:
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.error)
        }
    }
    
    func createEmptyCar() -> Car {
        return Car(license_plate: "AAA111", brand_id: 1, brand: "", model: "", codename: "", year: 0, comment: "", is_new: 1, latitude: 37.332914, longitude: -122.005202)
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
