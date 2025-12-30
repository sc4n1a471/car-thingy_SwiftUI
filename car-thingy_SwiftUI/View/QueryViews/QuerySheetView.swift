//
//  QuerySheet.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 5/21/23.
//

import SwiftUI
import CocoaLumberjackSwift
import MapKit

struct QuerySheetView: View {
	@Environment(SharedViewData.self) private var sharedViewData
    @State private var viewModel = ViewModel()
    @State private var locationManager = LocationManager()
    @State private var location: CLLocation?
	@State private var verificationCode: String = String()
    @Environment(\.presentationMode) var presentationMode
    var knownCarQuery: Bool = true
    
    let columns = [
        GridItem(.flexible(minimum: 275, maximum: 425)),
        GridItem(.flexible(minimum: 25, maximum: 75))
    ]
    let columns2 = [
        GridItem(.flexible(minimum: 100, maximum: 400))
    ]
    
    // MARK: Body
    var body: some View {
		// required because can't use environment as binding
		@Bindable var sharedViewDataBindable = sharedViewData
		
        NavigationStack {
            List {
                if !viewModel.inspectionsOnly {
                    Section {
                        withAnimation {
                            LazyVGrid(columns: sharedViewData.socketio.isLoading ? columns : columns2, content: {
                                if sharedViewData.socketio.isLoading {
                                    showLogs
                                    closeConnection
                                } else {
                                    saveCar
                                }
                            })
                        }
                    }
                    .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
                    
                    Section {
                        SpecView(header: "Brand", content: sharedViewData.socketio.car.brand)
                        SpecView(header: "Model", content: sharedViewData.socketio.car.model)
                        SpecView(header: "Type Code", content: sharedViewData.socketio.car.typeCode)
                    }
                    
                    Section {
                        SpecView(header: "Status", content: sharedViewData.socketio.car.status)
                        SpecView(header: "First registration", content: sharedViewData.socketio.car.firstReg)
                        SpecView(header: "First registration in 🇭🇺", content: sharedViewData.socketio.car.firstRegHun)
                        SpecView(header: "Number of owners", content: String(sharedViewData.socketio.car.numOfOwners ?? 900))
                    }
                    
                    Section {
                        SpecView(header: "Year", content: String(sharedViewData.socketio.car.year ?? 9995))
                        SpecView(header: "Engine size", content: String(sharedViewData.socketio.car.engineSize ?? 4290), note: "cm3")
                        SpecView(header: "Performance", content: String(sharedViewData.socketio.car.performance ?? 1000), note: "HP")
                        SpecView(header: "Fuel type", content: sharedViewData.socketio.car.fuelType)
                        SpecView(header: "Gearbox", content: sharedViewData.socketio.car.gearbox)
                        SpecView(header: "Color", content: sharedViewData.socketio.car.color)
                    }
                    
                    Section {
                        MileageView(onChangeMileageData: sharedViewData.socketio.car.mileage, mileageData: $sharedViewDataBindable.socketio.car.mileage)
                    }
                    
                    Section {
                        SpecView(header: "Restrictions", restrictions: sharedViewData.socketio.car.restrictions)
                    }
                    
                    Section {
                        SpecView(header: "Accidents", accidents: sharedViewData.socketio.car.accidents)
                    }
                }
                
                InspectionsView(inspections: sharedViewData.socketio.car.inspections)
            }
            // MARK: Toolbar items
            .toolbar {
#if os(macOS)
                ToolbarItem(placement: .navigationBarLeading, content: {
                    close
                        .disabled(sharedViewData.socketio.isLoading)
                })
#endif
            }
            .navigationTitle(sharedViewData.socketio.getLP())
        }
        // MARK: Alerts
		.alert(sharedViewData.socketio.error, isPresented: $sharedViewDataBindable.socketio.isAlertSheetView, actions: {
            Button("sharedViewData.socketio got it") {
                sharedViewData.socketio.disableAlert()
                print("sharedViewData.socketio alert confirmed")
            }
        })
		.alert("2FA", isPresented: $sharedViewDataBindable.socketio.verificationDialogOpen) {
			SecureField(text: $verificationCode) {}
			
			Button("Cancel") {
				sharedViewData.socketio.close()
			}
			
			Button("Submit") {
				sharedViewData.socketio.dismissCodeDialog(verificationCode: verificationCode)
			}
		} message: {
			Text("Pls gimme 2fa code")
		}
        // MARK: OnAppear
        .onAppear {
            sharedViewData.haptic(type: .standard)
			Task {
				DDLogDebug("=============== QuerySheetView open ===============")
                await updateLocation()
			}
        }
    }
    
    // MARK: Close
    var close: some View {
        Button(action: {
//            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Close")
        })
    }
    
    // MARK: Close connection
    var closeConnection: some View {
        Button(action: {
            sharedViewData.socketio.close()
//			sharedViewData.showMiniQueryView = false
        }, label: {
            Image(systemName: "xmark")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
        .buttonStyle(.bordered)
        .tint(.red)
    }
    
    // MARK: Save car
    var saveCar: some View {
        Button(action: {
            Task {
				if let safeLocationManagerMessage = locationManager.message {
					sharedViewData.socketio.showAlert(.querySheetView, safeLocationManagerMessage)
//					sharedViewData.showMiniQueryView = false
					return
				}
				
				if (locationManager.lastLocation.coordinate.latitude == 40.748443 && locationManager.lastLocation.coordinate.latitude == -73.985650) {
                    DDLogError("Location is Empire State Building")
					sharedViewData.socketio.showAlert(.querySheetView,  "The location data was pointing to Empire State Building, try again...")
					locationManager = LocationManager()
                } else {
                    if await viewModel.saveCar(websocket: sharedViewData.websocket, knownCarQuery: knownCarQuery, locationManager: locationManager) {
						sharedViewData.socketio.isSuccess = false
						sharedViewData.socketio.areImagesLoaded = false
                        presentationMode.wrappedValue.dismiss()
                    }
                }
//				sharedViewData.showMiniQueryView = false
            }
        }, label: {
            Image(systemName: "square.and.arrow.down")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(height: 50)
        })
        .buttonStyle(.bordered)
        .tint(.green)
		.disabled(!sharedViewData.socketio.areImagesLoaded)
    }
    
    // MARK: Show Logs
    var showLogs: some View {
        Button(action: {
            viewModel.setPopover(true)
        }) {
            Gauge(value: sharedViewData.socketio.percentage, in: 0...100) {}
                .gaugeStyle(.accessoryCircularCapacity)
                .tint(.blue)
                .scaleEffect(0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }.popover(isPresented: $viewModel.showingPopover) {
            ForEach(sharedViewData.socketio.messages, id: \.self) { message in
                Text(message)
            }
            .presentationCompactAdaptation((.popover))
            .padding(10)
        }
        .buttonStyle(.bordered)
        .tint(.blue)
    }
    
    // MARK: Get the current user location if available
    func updateLocation() async {
        do {
            DDLogVerbose("Getting location...")
            // 1. Get the current location from the location manager
            self.location = try await locationManager.currentLocation
            DDLogVerbose("Got location: \(self.location)")
        } catch {
            DDLogError("Could not get user location: \(error.localizedDescription)")
        }
    }
}

// MARK: Previews
#Preview {
    QuerySheetView()
		.environment(SharedViewData())
}

#Preview {
	ContentView()
		.environment(SharedViewData())
}
