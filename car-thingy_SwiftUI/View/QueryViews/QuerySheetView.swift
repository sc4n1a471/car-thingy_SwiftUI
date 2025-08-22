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
    
    var body: some View {
		// required because can't use environment as binding
		@Bindable var sharedViewDataBindable = sharedViewData
		
        NavigationStack {
            List {
                if !viewModel.inspectionsOnly {
                    Section {
                        withAnimation {
                            LazyVGrid(columns: sharedViewData.websocket.isLoading ? columns : columns2, content: {
                                if sharedViewData.websocket.isLoading {
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
                        SpecView(header: "Brand", content: sharedViewData.websocket.brand)
                        SpecView(header: "Model", content: sharedViewData.websocket.model)
                        SpecView(header: "Type Code", content: sharedViewData.websocket.type_code)
                    }
                    
                    Section {
                        SpecView(header: "Status", content: sharedViewData.websocket.status)
						SpecView(header: "First registration", content: sharedViewData.websocket.first_reg)
						SpecView(header: "First registration in 🇭🇺", content: sharedViewData.websocket.first_reg_hun)
                        SpecView(header: "Number of owners", content: String(sharedViewData.websocket.num_of_owners))
                    }
                    
                    Section {
                        SpecView(header: "Year", content: String(sharedViewData.websocket.year))
                        SpecView(header: "Engine size", content: String(sharedViewData.websocket.engine_size), note: "cm3")
                        SpecView(header: "Performance", content: String(sharedViewData.websocket.performance), note: "HP")
                        SpecView(header: "Fuel type", content: String(sharedViewData.websocket.fuel_type))
                        SpecView(header: "Gearbox", content: String(sharedViewData.websocket.gearbox))
                        SpecView(header: "Color", content: String(sharedViewData.websocket.color))
                    }
                    
                    Section {
                        MileageView(onChangeMileageData: sharedViewData.websocket.mileage, mileageData: $sharedViewDataBindable.websocket.mileage)
                    }
                    
                    Section {
                        SpecView(header: "Restrictions", restrictions: sharedViewData.websocket.restrictions)
                    }
                    
                    Section {
                        SpecView(header: "Accidents", accidents: sharedViewData.websocket.accidents)
                    }
                }
                
                InspectionsView(inspections: sharedViewData.websocket.inspections)
            }
            // MARK: Toolbar items
            .toolbar {
#if os(macOS)
                ToolbarItem(placement: .navigationBarLeading, content: {
                    close
                        .disabled(sharedViewData.websocket.isLoading)
                })
#endif
            }
            .navigationTitle(sharedViewData.websocket.getLP())
        }
		.alert(sharedViewData.websocket.error, isPresented: $sharedViewDataBindable.websocket.isAlertSheetView, actions: {
            Button("sharedViewData.websocket got it") {
                sharedViewData.websocket.disableAlert()
                print("sharedViewData.websocket alert confirmed")
            }
        })
		.alert("2FA", isPresented: $sharedViewDataBindable.websocket.verificationDialogOpen) {
			SecureField(text: $verificationCode) {}
			
			Button("Cancel") {
				sharedViewData.websocket.close()
			}
			
			Button("Submit") {
				sharedViewData.websocket.dismissCodeDialog(verificationCode: verificationCode)
			}
		} message: {
			Text("Pls gimme 2fa code")
		}
        .onAppear {
            sharedViewData.haptic(type: .standard)
			Task {
				DDLogDebug("=============== QuerySheetView open ===============")
                await updateLocation()
			}
        }
    }
    
    var close: some View {
        Button(action: {
//            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Close")
        })
    }
    
    var closeConnection: some View {
        Button(action: {
            sharedViewData.websocket.close()
//			sharedViewData.showMiniQueryView = false
        }, label: {
            Image(systemName: "xmark")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
        .buttonStyle(.bordered)
        .tint(.red)
    }
    
    var saveCar: some View {
        Button(action: {
            Task {
				if let safeLocationManagerMessage = locationManager.message {
					sharedViewData.websocket.showAlert(.querySheetView, safeLocationManagerMessage)
//					sharedViewData.showMiniQueryView = false
					return
				}
				
				if (locationManager.lastLocation.coordinate.latitude == 40.748443 && locationManager.lastLocation.coordinate.latitude == -73.985650) {
                    DDLogError("Location is Empire State Building")
					sharedViewData.websocket.showAlert(.querySheetView,  "The location data was pointing to Empire State Building, try again...")
					locationManager = LocationManager()
                } else {
                    if await viewModel.saveCar(websocket: sharedViewData.websocket, knownCarQuery: knownCarQuery, locationManager: locationManager) {
						sharedViewData.websocket.isSuccess = false
						sharedViewData.websocket.areImagesLoaded = false
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
		.disabled(!sharedViewData.websocket.areImagesLoaded)
    }
    
    var showLogs: some View {
        Button(action: {
            viewModel.setPopover(true)
        }) {
            Gauge(value: sharedViewData.websocket.percentage, in: 0...100) {}
                .gaugeStyle(.accessoryCircularCapacity)
                .tint(.blue)
                .scaleEffect(0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }.popover(isPresented: $viewModel.showingPopover) {
            ForEach(sharedViewData.websocket.messages, id: \.self) { message in
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

#Preview {
    QuerySheetView()
		.environment(SharedViewData())
}

#Preview {
	ContentView()
		.environment(SharedViewData())
}
