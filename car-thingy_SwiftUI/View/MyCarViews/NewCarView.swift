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
import CocoaLumberjackSwift

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
    @State var location: CLLocation?
    @State private var position: MapCameraPosition = .automatic
    // MARK: Position of the MapCamera
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
                    return ezLenniCar.licensePlate
                    
            },
                set: { newString in
                    self.ezLenniCar.licensePlate = newString.uppercased()
                    self.ezLenniCar.licensePlate.removeAll(where: {
                        removableCharacters.contains($0)
                    })
            })
    }
    var textBindingComment: Binding<String> {
            Binding<String>(
                get: {
					return self.ezLenniCar.comment ?? ""
            },
                set: { newString in
                    self.ezLenniCar.comment = newString
            })
    }
    
    var body: some View {
        // required because can't use environment as binding
        @Bindable var sharedViewDataBindable = sharedViewData
        
        NavigationStack {
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
								.padding()
                            TextField("Custom longitude", text: $customLongitude)
                                .keyboardType(.decimalPad)
								.padding()
                        } else if (selectedMap == MapType.current || isUpload) {
                            Map(position: $position) {
								UserAnnotation()
							}.frame(height: 200)
                        } else if (selectedMap == MapType.existing || !isUpload) {
							Map(initialPosition: .region(sharedViewData.region)) {
								Marker("", coordinate: ezLenniCar.getLocation().center)
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
			.alert("Error", isPresented: $sharedViewDataBindable.showAlertNewCar, actions: {
                Button("Got it") {
                    sharedViewData.showAlertNewCar = false
                }
            }, message: {
				Text(sharedViewData.error ?? "Some kind of error?")
            })
            
            // MARK: Toolbar items
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    close
                })
                ToolbarItemGroup(placement: .navigationBarTrailing, content: {
					if sharedViewData.isLoading {
						ProgressView()
							.progressViewStyle(CircularProgressViewStyle())
					} else {
						save
					}
                })
            }
			.scrollContentBackground(.visible)
        }
        .onAppear() {
            sharedViewData.haptic(type: .notification)
            if (sharedViewData.isEditCarPresented) {
                self.ezLenniCar = sharedViewData.existingCar
				oldLicensePlate = sharedViewData.existingCar.licensePlate
				
				customLatitude = sharedViewData.region.center.latitude.description
				customLongitude = sharedViewData.region.center.longitude.description
            } else {
				sharedViewData.clearExistingCar()
                self.ezLenniCar = sharedViewData.newCar
                sharedViewData.is_new = true
				sharedViewData.returnNewCar = Car()
                DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(1)) {
                    focusedField = .newLicensePlate
                }
            }
            Task { await self.updateLocation() }
        }
    }
    
    // MARK: Button functions
    var save: some View {
        Button(action: {
            Task {
                sharedViewData.isLoading = true
                
                if (selectedMap == MapType.custom) {
                    ezLenniCar.latitude = Double(customLatitude) ?? 37.789467
                    ezLenniCar.longitude = Double(customLongitude) ?? -122.416772
                } else if (selectedMap == MapType.current) {
					if let safeLocationManagerMessage = locationManager.message {
						sharedViewData.showAlert(.newCar, safeLocationManagerMessage)
						return
					}
                        
                    do {
                        DDLogVerbose("AppIntent: Getting location...")
                        location = try await locationManager.currentLocation
                        DDLogVerbose("NewCar: Got location: \(location)")
                        DDLogVerbose("NewCar: \(locationManager.region.center.latitude), \(locationManager.region.center.longitude)")
                        ezLenniCar.latitude = location!.coordinate.latitude
                        ezLenniCar.longitude = location!.coordinate.longitude

                    } catch {
                        DDLogError("Could not get user location: \(error.localizedDescription)")
                    }
                }
                
                oldLicensePlate = oldLicensePlate.uppercased()
                oldLicensePlate.removeAll(where: {
                    removableCharacters.contains($0)
                })
                
				ezLenniCar.updatedAt = Date.now.ISO8601Format()
				ezLenniCar.mileage = []
				
				ezLenniCar.createdAt = isUpload ? Date.now.ISO8601Format() : sharedViewData.existingCar.createdAt
				
				if ezLenniCar.licensePlate != oldLicensePlate && sharedViewData.isEditCarPresented {
					let (safeMessage, safeError) = await updateLicensePlate(newCarObject: ezLenniCar, oldLicensePlate: oldLicensePlate)
					
					if let safeMessage {
						DDLogVerbose("Licese plate update was successful: \(safeMessage)")
					}
					
					if let safeError {
						sharedViewData.showAlert(.newCar, "Licese plate update failed: \(safeError)")
						return
					}
				}
                
                let (safeMessage, safeError) = await saveData(uploadableCarData: ezLenniCar, isPost: isUpload, lpOnly: false)
                sharedViewData.isLoading = false
                
                if let safeMessage {
                    sharedViewData.isEditCarPresented = false
					sharedViewData.returnNewCar = ezLenniCar
					sharedViewData.existingCar = ezLenniCar
                    sharedViewData.haptic()
					DDLogVerbose("Upload was successful: \(safeMessage)")
                    presentationMode.wrappedValue.dismiss()
                }
                
                if let safeError {
                    sharedViewData.showAlert(.newCar, "Upload failed: \(safeError)")
					return
                }
            }
        }, label: {
			Image(systemName: "arrow.down")
				.foregroundStyle(.white)
        })
		.buttonStyle(.borderedProminent)
		.disabled(ezLenniCar.licensePlate.isEmpty)
    }
    
    var close: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Image(systemName: "xmark")
        })
		.tint(.red)
		.buttonStyle(.borderedProminent)
    }
    
    // MARK: Get the current user location if available
    func updateLocation() async {
        do {
            DDLogVerbose("Getting location...")
            // 1. Get the current location from the location manager
            self.location = try await locationManager.currentLocation
            DDLogVerbose("Got location: \(self.location)")
            // 2. Update the camera position of the map to center around the user location
            self.updateMapPosition()
        } catch {
            DDLogError("Could not get user location: \(error.localizedDescription)")
        }
    }
    
    // MARK: Change the camera of the Map view
    func updateMapPosition() {
        if let location = self.location {
            let regionCenter = CLLocationCoordinate2D(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            let regionSpan = MKCoordinateSpan(latitudeDelta: 0.125, longitudeDelta: 0.125)
            
            self.position = .region(MKCoordinateRegion(center: regionCenter, span: regionSpan))
        }
    }
}

#Preview {
	NewCar(isUpload: false)
		.environment(SharedViewData())
}
