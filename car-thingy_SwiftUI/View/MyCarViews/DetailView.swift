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
    
    @State var selectedCar: Car
    @State var region: MKCoordinateRegion
    @State private var enableScrollView: Bool = true
    
    @State var websocket: Websocket = Websocket()
    
    var body: some View {
            // required because can't use environment as binding
        @Bindable var sharedViewDataBindable = sharedViewData
        
        List {
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
                
                Group {
                    SpecView(header: "Accidents", accidents: selectedCar.accidents)
                }
                
                InspectionsView(inspections: selectedCar.inspections!)
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
            
            SpecView(header: "Comment", content: selectedCar.license_plate.comment)
        }
        .navigationTitle(selectedCar.getLP())
#if os(iOS)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing, content: {
                Button(action: {
                    websocket.openSheet()
                }) {
                    Gauge(value: websocket.percentage, in: 0...100) {}
                        .gaugeStyle(.accessoryCircularCapacity)
                        .tint(.blue)
                        .scaleEffect(0.5)
                        .frame(width: 25, height: 25)
                    
                }
                .isHidden(!websocket.isLoading)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .isHidden(!sharedViewData.isLoading)
                
                queryButton
                    .disabled(websocket.isLoading)
                
                editButton
                    .disabled(sharedViewData.isLoading)
            })
        }
#endif
        .sheet(isPresented: $sharedViewDataBindable.isEditCarPresented, onDismiss: {
            Task {
                await loadSelectedCar()
            }
        }) {
            NewCar(isUpload: false)
        }
        .sheet(isPresented: $websocket.dataSheetOpened, onDismiss: {
            Task {
                websocket.dismissSheet()
                await loadSelectedCar()
            }
        }) {
            QuerySheetView(websocket: websocket)
                .presentationDetents([.medium, .large])
        }
        .onAppear() {
            sharedViewData.existingCar = selectedCar
            sharedViewData.region = region
            Task {
                await loadSelectedCar()
            }
        }
    }
    
    var editButton: some View {
        Button (action: {
            sharedViewData.isEditCarPresented.toggle()
        }, label: {
            Image(systemName: "pencil")
        })
        .buttonStyle(.bordered)
    }
    
    var queryButton: some View {
        Button(action: {
            Task {
                await websocket.connect(_:selectedCar.license_plate.license_plate)
            }
        }, label: {
            Image(systemName: "magnifyingglass")
        })
        .buttonStyle(.borderedProminent)
    }
    
    func loadSelectedCar() async {
        sharedViewData.isLoading = true
        let (safeCar, safeCarError) = await loadCar(license_plate: sharedViewData.existingCar.license_plate.license_plate)
        if let safeCar {
            sharedViewData.existingCar = safeCar[0]
            selectedCar = sharedViewData.existingCar
        }
        
        if let safeCarError {
            sharedViewData.error = safeCarError
            sharedViewData.showAlert = true
            MyCarsView().haptic(type: .error)
        }
        
        sharedViewData.isLoading = false
    }
}

struct View2_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(selectedCar: previewCar, region: previewCar.getLocation())
            .environment(SharedViewData())
    }
}
