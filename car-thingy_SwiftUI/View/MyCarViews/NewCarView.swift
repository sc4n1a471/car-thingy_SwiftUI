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
    @State private var customLatitude: String = String()
    @State private var customLongitude: String = String()
    @State private var selectedMap = MapType.custom
	
	var userLatitude: String {
		return "\(locationManager.lastLocation.coordinate.latitude)"
	}
	
	var userLongitude: String {
		return "\(locationManager.lastLocation.coordinate.longitude)"
	}
	    
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
							Map(initialPosition: .region(locationManager.region)){
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
					}
                    
                    save
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
					
					if locationManager.region.center.latitude == 40.748443 && locationManager.region.center.longitude == -73.985650 {
						sharedViewData.showAlert(.newCar, "The location data was 0, try again...")
						return
					}
                        
					ezLenniCar.latitude = Double(userLatitude) ?? 127.0
					ezLenniCar.longitude = Double(userLongitude) ?? 36.0
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
		.disabled(sharedViewData.isLoading)
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
}

#Preview {
	NewCar(isUpload: false)
		.environment(SharedViewData())
}
