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

    @State var selectedCar: Car = Car()
    @State var selectedLicensePlate: String
    @State private var enableScrollView: Bool = true
    @State var websocket: Websocket = Websocket()
    
    var body: some View {
            // required because can't use environment as binding
        @Bindable var sharedViewDataBindable = sharedViewData
        
        NavigationStack {
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
                    
                        //                if enableScrollView {
                        //                    Section {
                        //                        if selectedCar.inspections!.count == 1 {
                        //                            ForEach(selectedCar.inspections!, id: \.self) { inspection in
                        //                                Section {
                        //                                    InspectionView(inspection: inspection)
                        //                                        .frame(width: 391, height: 300)
                        //                                }
                        //                                .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        //                            }
                        //                        } else {
                        //                            ScrollView(.horizontal) {
                        //                                HStack {
                        //                                    ForEach(selectedCar.inspections!, id: \.self) { inspection in
                        //                                        Section {
                        //                                            InspectionView(inspection: inspection)
                        //                                                .frame(width: 300, height: 300)
                        //                                        }
                        //                                        .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        //                                    }
                        //                                    .listStyle(.plain)
                        //                                }
                        //                            }
                        //                        }
                        //                    } header: {
                        //                        Text("Inspections")
                        //                    }
                        //                    .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        //                    .edgesIgnoringSafeArea(.all)
                        //                    .listStyle(GroupedListStyle()) // or PlainListStyle()
                        //                                                   /// iOS 17: https://www.hackingwithswift.com/quick-start/swiftui/how-to-make-a-scrollview-snap-with-paging-or-between-child-views
                        //                } else {
                        //                    ForEach(selectedCar.inspections!, id: \.self) { inspection in
                        //                        Section {
                        //                            InspectionView(inspection: inspection)
                        //                                .frame(height: 300)
                        //                        }
                        //                        .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        //                    }
                        //                }
                }
                
                SpecView(header: "Comment", content: selectedCar.license_plate.comment)
            }
            .navigationTitle(selectedCar.getLP())
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
        }
        .onAppear() {
            Task {
                await loadSelectedCar()
            }
        }
        .background(content: {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
        })
    }
    
    var editButton: some View {
        Button (action: {
            sharedViewData.isEditCarPresented.toggle()
        }, label: {
            Image(systemName: "pencil")
        })
    }
    
    var queryButton: some View {
        Button(action: {
            Task {
                await websocket.connect(_:selectedCar.license_plate.license_plate)
            }
        }, label: {
            Image(systemName: "magnifyingglass")
        })
    }
    
    func loadSelectedCar() async {
        sharedViewData.isLoading = true
        let (safeCar, safeCarError) = await loadCar(license_plate: selectedLicensePlate)
        if let safeCar {
            selectedCar = safeCar[0]
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
