//
//  NewCar.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/8/22.
//

import SwiftUI
import CoreLocation
import CoreLocationUI
import MapKit

enum MapType: String {
    case custom = "customMap"
    case current = "currentMap"
    case existing = "existingMap"
}

struct NewCar: View {
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var sharedViewData: SharedViewData
    
    private var isUpload: Bool
    @State private var year: String = ""     // TODO: Figure out why I have textYearBinding for year
    @State private var ezLenniCar = Car(license_plate: "aaaaaa", brand_id: 1, brand: "", model: "", codename: "", year: 0, comment: "", is_new: 1, latitude: 37.332914, longitude: -122.005202)
    @State private var isNewBrand = false
    @State private var oldLicensePlate = ""
    
    @StateObject var locationManager = LocationManager()
    @State private var customLatitude: String = ""
    @State private var customLongitude: String = ""
    @State private var selectedMap = MapType.custom
    
    init(isUpload: Bool, isNewBrand: State<Bool> = State(initialValue: false)) {
        self.isUpload = isUpload
        self._isNewBrand = isNewBrand
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
                    return ezLenniCar.license_plate
                    
            },
                set: { newString in
                    self.ezLenniCar.license_plate = newString.uppercased()
                    self.ezLenniCar.license_plate.removeAll(where: {
                        removableCharacters.contains($0)
                    })
            })
    }
    var textBindingBrand: Binding<String> {
            Binding<String>(
                get: {
                    if (self.ezLenniCar.brand == "DEFAULT_VALUE") {
                        return ""
                    }
                    return self.ezLenniCar.brand
                    
            },
                set: { newString in
                    self.ezLenniCar.brand = newString
            })
    }
    var textBindingModel: Binding<String> {
            Binding<String>(
                get: {
                    if (self.ezLenniCar.model == "DEFAULT_VALUE") {
                        return ""
                    }
                    return self.ezLenniCar.model
                    
            },
                set: { newString in
                    self.ezLenniCar.model = newString
            })
    }
    var textBindingCodename: Binding<String> {
            Binding<String>(
                get: {
                    if (self.ezLenniCar.codename == "DEFAULT_VALUE") {
                        return ""
                    }
                    return self.ezLenniCar.codename
                    
            },
                set: { newString in
                    self.ezLenniCar.codename = newString
            })
    }
    var textBindingYear: Binding<String> {
            Binding<String>(
                get: {
                    if Int(self.year) == 1901 {
                        return ""
                    }
                    return self.year
            },
                set: { newString in
                    self.year = newString
            })
    }
    var textBindingComment: Binding<String> {
            Binding<String>(
                get: {
                    if self.ezLenniCar.comment == "DEFAULT_VALUE" {
                        return ""
                    }
                    return self.ezLenniCar.comment
            },
                set: { newString in
                    self.ezLenniCar.comment = newString
            })
    }
    
    var body: some View {
        
        NavigationView {
            Form {
                Section {
                    TextField("License Plate", text: textBindingLicensePlate)
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
                            coordinateRegion: $sharedViewData.region,
                            interactionModes: MapInteractionModes.all,
                            annotationItems: [ezLenniCar]
                        ) {
                            MapMarker(coordinate: $0.getLocation().center)
                        }
                            .frame(height: 200)
                    }
                }
                
                Toggle("Unknown car", isOn: $sharedViewData.is_new)
                if !sharedViewData.is_new {
                    Section {
                        Toggle("Unknown brand", isOn: $isNewBrand)
                        if isNewBrand {
                            TextField("Brand", text: textBindingBrand)
                        } else {
                            Picker("Brand", selection: $sharedViewData.selectedBrand) {
                                ForEach(sharedViewData.brands, id: \.brand_id) { brand in
                                    if (brand.brand != "DEFAULT_VALUE" && brand.brand != "ERROR") {
                                        Text(brand.brand)
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Brand")
                    }
                    
//                    let _ = Self._printChanges()
//                    Text("What could possibly go wrong?")
                    
                    Section {
                        TextField("Model", text: textBindingModel)
                    } header: {
                        Text("Model")
                    }
                    
                    Section {
                        TextField("Codename", text: textBindingCodename)
                    } header: {
                        Text("Codename")
                    }
                    
                    Section {
                        TextField("Year", text: textBindingYear)
                            .keyboardType(.decimalPad)
                    } header: {
                        Text("Year")
                    }
                    
                    Section {
                        TextField("Comment", text: textBindingComment)
                    } header: {
                        Text("Comment")
                    }
                }
            }
            .alert("Error", isPresented: $sharedViewData.showAlert, actions: {
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
        }
        .onAppear() {
            if (sharedViewData.isEditCarPresented) {
                self.ezLenniCar = sharedViewData.existingCar
                self.year = String(sharedViewData.existingCar.year)
            } else {
                self.ezLenniCar = sharedViewData.newCar
                sharedViewData.selectedBrand = 1
                sharedViewData.is_new = true
            }
            oldLicensePlate = sharedViewData.existingCar.license_plate
        }
    }
    
    
    // MARK: Button functions
    var save: some View {
        Button(action: {
            Task {
                sharedViewData.isLoading = true
                
                if (selectedMap == MapType.custom) {
                    print("customMap")
                    ezLenniCar.latitude = Double(customLatitude) ?? 37.789467
                    ezLenniCar.longitude = Double(customLongitude) ?? -122.416772
                } else if (selectedMap == MapType.current) {
                    print("currentMap")
                    ezLenniCar.latitude = locationManager.region.center.latitude
                    ezLenniCar.longitude = locationManager.region.center.longitude
                }
                print(ezLenniCar)
                
                if (!isNewBrand) {
                    for brand in sharedViewData.brands {
                        if (brand.brand_id == sharedViewData.selectedBrand) {
                            ezLenniCar.brand = brand.brand
                        }
                    }
                }
                
                ezLenniCar.year = Int(year) ?? 1901
                if (sharedViewData.is_new) {
                    ezLenniCar.is_new = 1
                } else {
                    ezLenniCar.is_new = 0
                }
                
                oldLicensePlate = oldLicensePlate.uppercased()
                oldLicensePlate.removeAll(where: {
                    removableCharacters.contains($0)
                })
                print("oldLicensePlate: \(oldLicensePlate)")
                
                var ezLenniCarData = CarData(car: ezLenniCar, oldLicensePlate: ezLenniCar.license_plate)
                print("ezLenniCarData1: \(ezLenniCarData)")
                
                if (oldLicensePlate != ezLenniCar.license_plate) {
                    ezLenniCarData.oldLicensePlate = oldLicensePlate
                }
                print("ezLenniCarData2: \(ezLenniCarData)")
                
                let successfullyUploaded = await saveData(uploadableCarData: ezLenniCarData, isUpload: isUpload)
                sharedViewData.isLoading = false
                if successfullyUploaded {
                    sharedViewData.isEditCarPresented = false
                    presentationMode.wrappedValue.dismiss()
                    print("Success: Upload")
                } else {
                    sharedViewData.showAlert = true
                    print("Failed: Upload")
                }
                presentationMode.wrappedValue.dismiss()
                
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
            .environmentObject(SharedViewData())
    }
}
