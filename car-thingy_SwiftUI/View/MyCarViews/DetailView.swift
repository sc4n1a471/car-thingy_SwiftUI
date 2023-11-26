    //
    //  View2.swift
    //  NodeJS_Thingy_Cars
    //
    //  Created by Martin Terhes on 7/3/22.
    //

import SwiftUI
import CoreLocation
import MapKit

struct DetailView: View {
    @Environment(SharedViewData.self) private var sharedViewData
    @Environment(\.presentationMode) var presentationMode

    @State var selectedCar: Car
    @State var region: MKCoordinateRegion
    @State private var enableScrollView: Bool = true
    
    @State var websocket: Websocket = Websocket()
    
    let columns = [
        GridItem(.flexible(minimum: 100, maximum: 200)),
        GridItem(.flexible(minimum: 100, maximum: 200))
    ]
    
    var body: some View {
            // required because can't use environment as binding
        @Bindable var sharedViewDataBindable = sharedViewData
        
        List {
            Section {
                withAnimation {
                    LazyVGrid(columns: columns, content: {
                        if sharedViewData.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            editButton
                        }
                        if websocket.isLoading {
                            openQuerySheet
                        } else {
                            queryButton
                        }
                    })
                }
            }
            .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            if selectedCar.specs.license_plate != String() {
                Section {
                    SpecView(header: "Brand", content: selectedCar.specs.brand)
                    SpecView(header: "Model", content: selectedCar.specs.model)
                    SpecView(header: "Type Code", content: selectedCar.specs.type_code)
                }
                
                Section {
                    SpecView(header: "Status", content: selectedCar.specs.status)
                    SpecView(header: "First registration", content: selectedCar.specs.first_reg)
                    SpecView(header: "First registration in 🇭🇺", content: selectedCar.specs.first_reg_hun)
                    SpecView(header: "Number of owners", content: String(selectedCar.specs.num_of_owners ?? 99))
                }
                
                Section {
                    SpecView(header: "Year", content: String(selectedCar.specs.year ?? 1970))
                    SpecView(header: "Engine size", content: String(selectedCar.specs.engine_size ?? 9999), note: "cm3")
                    SpecView(header: "Performance", content: String(selectedCar.specs.performance ?? 999), note: "HP")
                    SpecView(header: "Fuel type", content: selectedCar.specs.fuel_type)
                    SpecView(header: "Gearbox", content: selectedCar.specs.gearbox)
                    SpecView(header: "Color", content: selectedCar.specs.color)
                }
                
                Section {
                    MileageView(onChangeMileageData: websocket.mileage, mileageData: $selectedCar.mileage)
                }
                
                Section {
                    SpecView(header: "Restrictions", restrictions: selectedCar.restrictions)
                }
                
                Section {
                    SpecView(header: "Accidents", accidents: selectedCar.accidents)
                }
                
                Section {
                    InspectionsView(inspections: selectedCar.inspections ?? [Inspection()])
                }
            }
            
                // MARK: Map
            Section {
                Map(
                    coordinateRegion: $region,
                    interactionModes: MapInteractionModes.all,
                    annotationItems: [selectedCar]
                ) {
                    MapMarker(coordinate: $0.getLocation().center)
                }
                .frame(height: 200)
                .cornerRadius(10)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            Section {
                SpecView(header: "Comment", content: selectedCar.license_plate.comment)
            }
            
            Section {
                deleteButton
            }
            .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .navigationTitle(selectedCar.getLP())
        .sheet(isPresented: $sharedViewDataBindable.isEditCarPresented, onDismiss: {
            Task {
                await loadSelectedCar()
            }
        }) {
            NewCar(isUpload: false)
        }
        .sheet(isPresented: $websocket.dataSheetOpened, onDismiss: {
            Task {
                await websocket.dismissSheet()
                await loadSelectedCar()
            }
        }) {
            QuerySheetView(websocket: websocket)
                .presentationDetents([.medium, .large])
        }
        .alert(websocket.error, isPresented: $websocket.isAlert, actions: {
            Button("Websocket got it") {
                websocket.disableAlert()
                print("websocket alert confirmed")
            }
        })
        .onAppear() {
            sharedViewData.existingCar = selectedCar
            sharedViewData.region = region
            Task {
                await loadSelectedCar()
            }
        }
		.toolbar(content: {
			ToolbarItem(placement: .topBarTrailing, content: {
				DateView(licensePlate: selectedCar.license_plate, mapView: false)
					.frame(maxWidth: .infinity, alignment: .trailing)
			})
		})
    }
    
    // MARK: Button views
    var openQuerySheet: some View {
        Button(action: {
            websocket.openSheet()
        }) {
            Gauge(value: websocket.percentage, in: 0...100) {}
                .gaugeStyle(.accessoryCircularCapacity)
                .tint(.blue)
                .scaleEffect(0.5)
                .frame(width: 25, height: 25)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(.blue)
        .frame(height: 50)
    }
    
    var editButton: some View {
        Button (action: {
            sharedViewData.isEditCarPresented.toggle()
        }, label: {
            Image(systemName: "pencil")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
        .buttonStyle(.bordered)
        .frame(height: 50)
    }
    
    var queryButton: some View {
        Button(action: {
            Task {
                await websocket.connect(_:selectedCar.license_plate.license_plate)
            }
        }, label: {
            Image(systemName: "magnifyingglass")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
        .buttonStyle(.borderedProminent)
        .frame(height: 50)
    }
    
    var deleteButton: some View {
        Button(action: {
            Task {
                let (successMsg, errorMsg) = try await deleteCar(licensePlate: selectedCar.license_plate.license_plate)
                
                if successMsg != nil {
					await sharedViewData.loadViewData()
                    presentationMode.wrappedValue.dismiss()
                }
                
                if let safeErrorMsg = errorMsg {
                    sharedViewData.showAlert(errorMsg: safeErrorMsg)
                }
            }
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Image(systemName: "trash")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
        .buttonStyle(.bordered)
        .frame(height: 50)
        .tint(.red)
        .disabled(sharedViewData.isLoading)
    }
    
    // MARK: Functions
    func loadSelectedCar() async {
        sharedViewData.isLoading = true
        let (safeCar, safeCarError) = await loadCar(license_plate: sharedViewData.existingCar.license_plate.license_plate)
        if let safeCar {
            sharedViewData.existingCar = safeCar[0]
            selectedCar = sharedViewData.existingCar
        }
        
        if let safeCarError {
            sharedViewData.showAlert(errorMsg: safeCarError)
        }
        
        sharedViewData.isLoading = false
    }
}

#Preview {
    DetailView(selectedCar: previewCar, region: previewCar.getLocation())
        .environment(SharedViewData())
}
