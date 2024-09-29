//
//  QuerySheet.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 5/21/23.
//

import SwiftUI
import CocoaLumberjackSwift

struct QuerySheetView: View {
	@Environment(SharedViewData.self) private var sharedViewData
    @Bindable var websocket: Websocket
    @State private var viewModel = ViewModel()
    @State private var locationManager = LocationManager()
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
        NavigationStack {
            List {
                if !viewModel.inspectionsOnly {
                    Section {
                        withAnimation {
                            LazyVGrid(columns: websocket.isLoading ? columns : columns2, content: {
                                if websocket.isLoading {
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
                        SpecView(header: "Brand", content: websocket.brand)
                        SpecView(header: "Model", content: websocket.model)
                        SpecView(header: "Type Code", content: websocket.type_code)
                    }
                    
                    Section {
                        SpecView(header: "Status", content: websocket.status)
						SpecView(header: "First registration", content: websocket.first_reg)
						SpecView(header: "First registration in 🇭🇺", content: websocket.first_reg_hun)
                        SpecView(header: "Number of owners", content: String(websocket.num_of_owners))
                    }
                    
                    Section {
                        SpecView(header: "Year", content: String(websocket.year))
                        SpecView(header: "Engine size", content: String(websocket.engine_size), note: "cm3")
                        SpecView(header: "Performance", content: String(websocket.performance), note: "HP")
                        SpecView(header: "Fuel type", content: String(websocket.fuel_type))
                        SpecView(header: "Gearbox", content: String(websocket.gearbox))
                        SpecView(header: "Color", content: String(websocket.color))
                    }
                    
                    Section {
                        MileageView(onChangeMileageData: websocket.mileage, mileageData: $websocket.mileage)
                    }
                    
                    Section {
                        SpecView(header: "Restrictions", restrictions: websocket.restrictions)
                    }
                    
                    Section {
                        SpecView(header: "Accidents", accidents: websocket.accidents)
                    }
                }
                
                InspectionsView(inspections: websocket.inspections)
            }
            // MARK: Toolbar items
            .toolbar {
#if os(macOS)
                ToolbarItem(placement: .navigationBarLeading, content: {
                    close
                        .disabled(websocket.isLoading)
                })
#endif
            }
            .navigationTitle(websocket.getLP())
            .scrollContentBackground(.visible)
        }
		.alert(websocket.error, isPresented: $websocket.isAlertSheetView, actions: {
            Button("Websocket got it") {
                websocket.disableAlert()
                print("websocket alert confirmed")
            }
        })
        .onAppear {
            sharedViewData.haptic(type: .standard)
			Task {
				DDLogDebug("=============== QuerySheetView open ===============")
			}
        }
    }
    
    var close: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Close")
        })
    }
    
    var closeConnection: some View {
        Button(action: {
            websocket.close()
        }, label: {
            Image(systemName: "xmark")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(height: 50)
        })
        .buttonStyle(.bordered)
        .tint(.red)
    }
    
    var saveCar: some View {
        Button(action: {
            Task {
				if let safeLocationManagerMessage = locationManager.message {
					websocket.showAlert(.querySheetView, safeLocationManagerMessage)
					return
				}
				
				if (locationManager.lastLocation.coordinate.latitude == 40.748443 && locationManager.lastLocation.coordinate.latitude == -73.985650) {
                    DDLogError("Location is Empire State Building")
					websocket.showAlert(.querySheetView,  "The location data was pointing to Empire State Building, try again...")
					locationManager = LocationManager()
                } else {
                    if await viewModel.saveCar(websocket: websocket, knownCarQuery: knownCarQuery, locationManager: locationManager) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }, label: {
            Image(systemName: "square.and.arrow.down")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(height: 50)
        })
        .buttonStyle(.bordered)
        .tint(.green)
    }
    
    var showLogs: some View {
        Button(action: {
            viewModel.setPopover(true)
        }) {
            Gauge(value: websocket.percentage, in: 0...100) {}
                .gaugeStyle(.accessoryCircularCapacity)
                .tint(.blue)
                .scaleEffect(0.5)
                .frame(width: 25, height: 25)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }.popover(isPresented: $viewModel.showingPopover) {
            ForEach(websocket.messages, id: \.self) { message in
                Text(message)
            }
            .presentationCompactAdaptation((.popover))
            .padding(10)
        }
        .buttonStyle(.bordered)
        .tint(.blue)
    }
}

#Preview {
    QuerySheetView(websocket: Websocket(preview: true))
		.environment(SharedViewData())
}
