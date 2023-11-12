    //
    //  MapDetailView.swift
    //  car-thingy_SwiftUI
    //
    //  Created by Martin Terhes on 11/11/23.
    //

import SwiftUI
import MapKit

struct MapDetailView: View {
    @Environment(SharedViewData.self) private var sharedViewData
    
    @State private var selectedCar: Car = Car()
    @State var selectedLicensePlate: String
    @State private var enableScrollView: Bool = true
    @State private var websocket: Websocket = Websocket()
    
    let columns = [
        GridItem(.flexible(minimum: 100, maximum: 200)),
        GridItem(.flexible(minimum: 100, maximum: 200)),
        GridItem(.flexible(minimum: 100, maximum: 200))
    ]
    
    var body: some View {
            // required because can't use environment as binding
        @Bindable var sharedViewDataBindable = sharedViewData
        
        Text(selectedLicensePlate)
            .fontWeight(.bold)
            .font(.title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 20)
            .padding(.leading, 20)
        
        List {
            Section {
                LazyVGrid(columns: columns, content: {
                    editButton
                    queryButton
                    deleteButton
                })
//                .padding(.trailing, 20)
//                .padding(.leading, 20)
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
                
                Group {
                    SpecView(header: "Accidents", accidents: selectedCar.accidents)
                }
                
                if let safeInspections = selectedCar.inspections {
                    InspectionsView(inspections: safeInspections)
                }
            }
            
            SpecView(header: "Comment", content: selectedCar.license_plate.comment)
        }
        .onAppear() {
            Task {
                await loadSelectedCar()
            }
        }
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
            })
        }
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
        .background(.ultraThickMaterial)
        .scrollContentBackground(.hidden)
    }
    
    var editButton: some View {
        Button (action: {
            sharedViewData.isEditCarPresented.toggle()
        }, label: {
            Image(systemName: "pencil")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
        .buttonStyle(.bordered)
        .disabled(sharedViewData.isLoading)
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
        .disabled(websocket.isLoading)
    }
    
    var deleteButton: some View {
        // TODO: Make a functioning delete button
        Button(action: {
            Task {
                await websocket.connect(_:selectedCar.license_plate.license_plate)
            }
        }, label: {
            Image(systemName: "trash")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
        .buttonStyle(.bordered)
        .frame(height: 50)
        .disabled(true)
    }
    
    private func loadSelectedCar() async {
        sharedViewData.isLoading = true
        let (safeCar, safeCarError) = await loadCar(license_plate: selectedLicensePlate)
        if let safeCar {
            selectedCar = safeCar[0]
            sharedViewData.existingCar = selectedCar
            MyCarsView().haptic(type: .notification)
        }
        
        if let safeCarError {
            sharedViewData.error = safeCarError
            sharedViewData.showAlert = true
            MyCarsView().haptic(type: .error)
        }
        
        sharedViewData.isLoading = false
    }
}

#Preview {
    MapDetailView(selectedLicensePlate: "MIA192")
        .environment(SharedViewData())
}