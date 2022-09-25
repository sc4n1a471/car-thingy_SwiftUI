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
    
    @State var isPresented: Bool
    @State var isUpdate: Bool   // TODO: Figure out why I have isUpdate/isUpload seperate
    @State var isUpload: Bool
    @State var year: String     // TODO: Figure out why I have textYearBinding for year
    @State var is_new: Bool = true
    @State private var ezLenniCar: Car
    @State var showAlert = false
    @State var isLoading = false
    
//    @State var brands = [Brand]()
    @State var brands: [Brand]
    @State private var selectedBrand = 1
    @State var isNewBrand = false
    @State var oldLicensePlate = ""
    
    @State var region = MKCoordinateRegion(
        center:  CLLocationCoordinate2D(
          latitude: 37.789467,
          longitude: -122.416772
        ),
        span: MKCoordinateSpan(
          latitudeDelta: 0.01,
          longitudeDelta: 0.01
       )
    )
    @State var isTracking: MapUserTrackingMode = .none
    @StateObject var locationManager = LocationManager()
    @State var customLatitude: String = ""
    @State var customLongitude: String = ""
    @State var selectedMap = MapType.custom
    
    init(isPresented: State<Bool>, isUpdate: State<Bool>, isUpload: State<Bool>, year: State<String>, is_new: State<Bool>, ezLenniCar: State<Car>, showAlert: State<Bool> = State(initialValue: false), isLoading: State<Bool> = State(initialValue: false), brands: State<[Brand]>, isNewBrand: State<Bool> = State(initialValue: false), oldLicensePlate: State<String> = State(initialValue: ""), region: State<MKCoordinateRegion> = State(initialValue: MKCoordinateRegion(
        center:  CLLocationCoordinate2D(
            latitude: 37.789467,
            longitude: -122.416772
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.01,
            longitudeDelta: 0.01
        ))
    )) {
//        self.presentationMode = presentationMode
        self._isPresented = isPresented
        self._isUpdate = isUpdate
        self._isUpload = isUpload
        self._year = year
        self._is_new = is_new
        self._ezLenniCar = ezLenniCar
//        self.showAlert = showAlert
        self._isLoading = isLoading
        self._brands = brands
        self._selectedBrand = {
            return State(initialValue: ezLenniCar.wrappedValue.brand_id)
        }()
        self._isNewBrand = isNewBrand
        self._oldLicensePlate = oldLicensePlate
        self._region = region
//        self.isTracking = isTracking
//        self.locationManager = locationManager
//        self.customCoordinates = customCoordinates
//        self.customLatitude = customLatitude
//        self.customLongitude = customLongitude
        self._selectedMap = {
            if (isUpload.wrappedValue) {
                return State(initialValue: MapType.current)
            } else if (!isUpload.wrappedValue) {
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
                    return self.ezLenniCar.license_plate
                    
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
                            userTrackingMode: $isTracking
                        )
                            .frame(height: 200)
                    } else if (selectedMap == MapType.existing || !isUpload) {
                        Map(
                            coordinateRegion: $region,
                            interactionModes: MapInteractionModes.all,
                            annotationItems: [ezLenniCar]
                        ) {
                            MapMarker(coordinate: $0.getLocation().center)
                        }
                            .frame(height: 200)
                    }
                }
                
                Toggle("Unknown car", isOn: $is_new)
                if !is_new {
                    Section {
                        Toggle("Unknown brand", isOn: $isNewBrand)
                        if isNewBrand {
                            TextField("Brand", text: textBindingBrand)
                        } else {
                            Picker("Brand", selection: $selectedBrand) {
                                ForEach(brands, id: \.brand_id) { brand in
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
            }.alert("Error", isPresented: $showAlert, actions: {
                Button("Got it") {
                    showAlert = false
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
                        .isHidden(!isLoading)
                    
                    save
                        .disabled(isLoading)
                })
            }
        }
    }
    
    
    // MARK: Button functions
    var save: some View {
        Button(action: {
            Task {
                isLoading = true
                
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
                    for brand in brands {
                        if (brand.brand_id == selectedBrand) {
                            ezLenniCar.brand = brand.brand
                        }
                    }
                }
                
                ezLenniCar.year = Int(year) ?? 1901
                if (is_new) {
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
                
                let successfullyUploaded = await saveData(uploadableCarData: ezLenniCarData, isUpload: isUpload, isUpdate: isUpdate)
                isLoading = false
                if successfullyUploaded {
                    isPresented = false
                    presentationMode.wrappedValue.dismiss()
                    print("Success: Upload")
                } else {
                    showAlert = true
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

//struct NewCar_Previews: PreviewProvider {
//    static var previews: some View {
//        NewCar(
//            isPresented: State(initialValue: true),
//            isUpdate: State(initialValue: true),
//            isUpload: State(initialValue: false),
//            year: State(initialValue: ""),
//            is_new: State(initialValue: false),
//            ezLenniCar:
//                    .constant(
//                        Car(license_plate: "", brand_id: 1, brand: "", model: "", codename: "", year: 0, comment: "", is_new: 1, latitude: 46.229014679521015, longitude: 20.186523048482677)
//                    ),
//            brands: State(initialValue: [Brand(brand_id: 1, brand: "he"), Brand(brand_id: 2, brand: "hehe"), Brand(brand_id: 3, brand: "hehehe"), Brand(brand_id: 4, brand: "hehehehe"), Brand(brand_id: 5, brand: "hehehehehe"), Brand(brand_id: 5, brand: "hehehehe"), Brand(brand_id: 6, brand: "hehehehe"), Brand(brand_id: 7, brand: "hehehehe"), Brand(brand_id: 8, brand: "hehehehe"), Brand(brand_id: 9, brand: "hehehehe"), Brand(brand_id: 10, brand: "hehehehe"), Brand(brand_id: 11, brand: "hehehehe"), Brand(brand_id: 12, brand: "hehehehe"), Brand(brand_id: 13, brand: "hehehehe")]),
//            selectedBrand: State(initialValue: 1)
//        )
//    }
//}
