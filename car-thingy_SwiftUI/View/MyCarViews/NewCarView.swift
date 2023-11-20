//
//  NewCar.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/8/22.
//

import SwiftUI
import CoreLocation
#if canImport(CoreLocationUI)
import CoreLocationUI
#endif
import MapKit

enum MapType: String {
    case custom = "customMap"
    case current = "currentMap"
    case existing = "existingMap"
}
enum Field: Int, Hashable {
    case newLicensePlate
}

struct NewCar: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Environment(SharedViewData.self) private var sharedViewData
    
//    @State private var viewModel = ViewModel()

    @FocusState private var focusedField: Field?
    
    @State private var ezLenniCar: Car = Car()
    @State private var oldLicensePlate = String()
    
    @State var locationManager = LocationManager()
    @State private var customLatitude: String = String()
    @State private var customLongitude: String = String()
    @State private var selectedMap = MapType.custom
    
    private var isUpload: Bool
    
    init(isUpload: Bool, isNewBrand: State<Bool> = State(initialValue: false)) {
        self.isUpload = isUpload
        self._selectedMap = {
            if (isUpload) {
                return State(initialValue: MapType.current)
            } else if (!isUpload) {
                return  State(initialValue: MapType.existing)
            } else {
                return  State(initialValue: MapType.custom)
            }
        }()
    }
    
    let removableCharacters: Set<Character> = ["-"]
    var textBindingLicensePlate: Binding<String> {
            Binding<String>(
                get: {
                    return ezLenniCar.license_plate.license_plate
                    
            },
                set: { newString in
                    self.ezLenniCar.license_plate.license_plate = newString.uppercased()
                    self.ezLenniCar.license_plate.license_plate.removeAll(where: {
                        removableCharacters.contains($0)
                    })
            })
    }
    var textBindingComment: Binding<String> {
            Binding<String>(
                get: {
                    return self.ezLenniCar.license_plate.comment
            },
                set: { newString in
                    self.ezLenniCar.license_plate.comment = newString
            })
    }
    
    var body: some View {
        // required because can't use environment as binding
        @Bindable var sharedViewDataBindable = sharedViewData
        
        NavigationView {
            Form {
                Section {
                    TextField("License Plate", text: textBindingLicensePlate)
                        .focused($focusedField, equals: .newLicensePlate)
                } header: {
                    Text("License Plate")
                }
                
                Section {
                    Picker("Flavor", selection: $selectedMap) {
                        Text("Current Map").tag(MapType.current)
                        Text("Custom Map").tag(MapType.custom)
                        Text("Existing Map").tag(MapType.existing)
                    }
                    .pickerStyle(.segmented)
                    
                    Section {
                        if selectedMap == MapType.custom {
                            TextField("Custom latitude", text: $customLatitude)
                                .keyboardType(.decimalPad)
                            TextField("Custom longitude", text: $customLongitude)
                                .keyboardType(.decimalPad)
                        } else if (selectedMap == MapType.current || isUpload) {
                            Map(
                                coordinateRegion: $locationManager.region,
                                interactionModes: MapInteractionModes.all,
                                showsUserLocation: true,
                                userTrackingMode: .none
                            )
                            .frame(height: 200)
                        } else if (selectedMap == MapType.existing || !isUpload) {
                            Map(
                                coordinateRegion: $sharedViewDataBindable.region,
                                interactionModes: MapInteractionModes.all,
                                annotationItems: [ezLenniCar]
                            ) {
                                MapMarker(coordinate: $0.getLocation().center)
                            }
                            .frame(height: 200)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                
                Section {
                    TextField("Comment", text: textBindingComment)
                } header: {
                    Text("Comment")
                }
            }
            .alert("Error", isPresented: $sharedViewDataBindable.showAlert, actions: {
                Button("Got it") {
                    sharedViewData.showAlert = false
                }
            }, message: {
                Text("Could not connect to server!")
            })
            
            // MARK: Toolbar items
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    close
                })
                ToolbarItemGroup(placement: .navigationBarTrailing, content: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .isHidden(!sharedViewData.isLoading)
                    
                    save
                        .disabled(sharedViewData.isLoading)
                })
            }
			.scrollContentBackground(.visible)
        }
        .onAppear() {
            MyCarsView().haptic(type: .notification)
            if (sharedViewData.isEditCarPresented) {
                self.ezLenniCar = sharedViewData.existingCar
            } else {
                self.ezLenniCar = sharedViewData.newCar
                sharedViewData.is_new = true
                DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(1)) {
                    focusedField = .newLicensePlate
                }
            }
            oldLicensePlate = sharedViewData.existingCar.license_plate.license_plate
        }
    }
    
    // MARK: Button functions
    var save: some View {
        Button(action: {
            Task {
                sharedViewData.isLoading = true
                
                if (selectedMap == MapType.custom) {
                    ezLenniCar.coordinates.latitude = Double(customLatitude) ?? 37.789467
                    ezLenniCar.coordinates.longitude = Double(customLongitude) ?? -122.416772
                } else if (selectedMap == MapType.current) {
                    var counter = 0
                    while (locationManager.region.center.latitude == 0 && locationManager.region.center.longitude == 0 && counter != 100) {
                        print("Location is 0")
                        counter += 1
                    }
                    if counter == 100 {
                        sharedViewData.showAlert(errorMsg: "The location data was 0, try again...")
                        
                        ezLenniCar.coordinates.latitude = locationManager.region.center.latitude
                        ezLenniCar.coordinates.longitude = locationManager.region.center.longitude
                    }
                }
                
                oldLicensePlate = oldLicensePlate.uppercased()
                oldLicensePlate.removeAll(where: {
                    removableCharacters.contains($0)
                })
                
                ezLenniCar.coordinates.license_plate = ezLenniCar.license_plate.license_plate
                ezLenniCar.license_plate.created_at = Date.now.ISO8601Format()
                
                let (safeMessage, safeError) = await saveData(uploadableCarData: ezLenniCar, isPost: isUpload, lpOnly: false)
                sharedViewData.isLoading = false
                
                if let safeMessage {
                    sharedViewData.isEditCarPresented = false
                    MyCarsView().haptic()
                    print("Upload was successful")
                    presentationMode.wrappedValue.dismiss()
                }
                
                if let safeError {
                    sharedViewData.showAlert(errorMsg: "Upload failed: \(safeError)")
                }
            }
        }, label: {
            Text("Save")
        })
    }
    
    var close: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Close")
        })
    }
}

struct NewCar_Previews: PreviewProvider {
    static var previews: some View {
        NewCar(isUpload: false)
            .environment(SharedViewData())
    }
}
