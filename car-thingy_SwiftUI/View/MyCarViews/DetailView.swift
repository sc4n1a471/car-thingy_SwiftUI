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
    @EnvironmentObject var sharedViewData: SharedViewData
    @EnvironmentObject var querySharedData: QuerySharedData
    
    @State private var selectedCar: Car
    @State private var region: MKCoordinateRegion
    @State private var enableScrollView: Bool = true
    
    @StateObject var websocket: Websocket = Websocket()
        
    init(selectedCar: Car) {
        self.selectedCar = selectedCar
        self.region = selectedCar.getLocation()
    }
    
    var body: some View {
        List {
            Section {
                SpecView(header: "Brand", content: selectedCar.specs.brand)
                SpecView(header: "Model", content: selectedCar.specs.model)
                SpecView(header: "Type Code", content: selectedCar.specs.type_code)
            }
            
            Section {
                SpecView(header: "Status", content: selectedCar.specs.status)
                SpecView(header: "First registration", content: selectedCar.specs.first_reg)
                SpecView(header: "First registration in 🇭🇺", content: selectedCar.specs.first_reg_hun)
                SpecView(header: "Number of owners", content: String(selectedCar.specs.num_of_owners))
            }
            
            Section {
                SpecView(header: "Year", content: String(selectedCar.specs.year))
                SpecView(header: "Engine size", content: String(selectedCar.specs.engine_size), note: "cm3")
                SpecView(header: "Performance", content: String(selectedCar.specs.performance), note: "HP")
                SpecView(header: "Fuel type", content: selectedCar.specs.fuel_type)
                SpecView(header: "Gearbox", content: selectedCar.specs.gearbox)
                SpecView(header: "Color", content: selectedCar.specs.color)
            }
            
            SpecView(header: "Comment", content: selectedCar.specs.comment)
            
            Section {
                MileageView(onChangeMileageData: websocket.mileage, mileageData: selectedCar.mileage!)
            }
            
            Section {
                SpecView(header: "Restrictions", restrictions: selectedCar.restrictions)
            }
            
            Group {
                SpecView(header: "Accidents", accidents: selectedCar.accidents)
            }
            
                ///https://www.swiftyplace.com/blog/customise-list-view-appearance-in-swiftui-examples-beyond-the-default-stylings
                //                if let safeInspections = websocket.inspections {
                //                    if enableScrollView {
                //                        Section {
                //                            if safeInspections.count == 1 {
                //                                ForEach(safeInspections, id: \.self) { safeInspection in
                //                                    Section {
                //                                        InspectionView(inspection: safeInspection)
                //                                            .frame(width: 391, height: 300)
                //                                    }
                //                                    .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                //                                }
                //                            } else {
                //                                ScrollView(.horizontal) {
                //                                    HStack {
                //                                        ForEach(safeInspections, id: \.self) { safeInspection in
                //                                            Section {
                //                                                InspectionView(inspection: safeInspection)
                //                                                    .frame(width: 300, height: 300)
                //                                            }
                //                                            .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                //                                        }
                //                                        .listStyle(.plain)
                //                                    }
                //                                }
                //                            }
                //                        } header: {
                //                            Text("Inspections")
                //                        }
                //                        .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                //                        .edgesIgnoringSafeArea(.all)
                //                        .listStyle(GroupedListStyle()) // or PlainListStyle()
                //                        /// iOS 17: https://www.hackingwithswift.com/quick-start/swiftui/how-to-make-a-scrollview-snap-with-paging-or-between-child-views
                //                    } else {
                //                        ForEach(safeInspections, id: \.self) { safeInspection in
                //                            Section {
                //                                InspectionView(inspection: safeInspection)
                //                                    .frame(height: 300)
                //                            }
                //                            .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                //                        }
                //                    }
                //                }
            
            if enableScrollView {
                Section {
                    if selectedCar.inspections!.count == 1 {
                        ForEach(selectedCar.inspections!, id: \.self) { inspection in
                            Section {
                                InspectionView(inspection: inspection)
                                    .frame(width: 391, height: 300)
                            }
                            .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        }
                    } else {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(selectedCar.inspections!, id: \.self) { inspection in
                                    Section {
                                        InspectionView(inspection: inspection)
                                            .frame(width: 300, height: 300)
                                    }
                                    .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                                }
                                .listStyle(.plain)
                            }
                        }
                    }
                } header: {
                    Text("Inspections")
                }
                .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                .edgesIgnoringSafeArea(.all)
                .listStyle(GroupedListStyle()) // or PlainListStyle()
                                               /// iOS 17: https://www.hackingwithswift.com/quick-start/swiftui/how-to-make-a-scrollview-snap-with-paging-or-between-child-views
            } else {
                ForEach(selectedCar.inspections!, id: \.self) { inspection in
                    Section {
                        InspectionView(inspection: inspection)
                            .frame(height: 300)
                    }
                    .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
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
                
                queryButton
                    .disabled(websocket.isLoading)
                
                editButton
                    .disabled(sharedViewData.isLoading)
            })
        }
#endif
        .sheet(isPresented: $sharedViewData.isEditCarPresented, onDismiss: {
            Task {
                sharedViewData.isLoading = true
                let (safeCar, safeCarError) = await loadCar(license_plate: sharedViewData.existingCar.specs.license_plate)
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
        }) {
            NewCar(isUpload: false)
        }
        .sheet(isPresented: $websocket.dataSheetOpened, onDismiss: {
            Task {
                websocket.dismissSheet()
            }
        }) {
            QuerySheetView()
                .presentationDetents([.medium, .large])
                .environmentObject(websocket)
        }
        .onAppear() {
            sharedViewData.existingCar = selectedCar
            sharedViewData.region = region
        }
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
                await websocket.connect(_:selectedCar.specs.license_plate)
            }
        }, label: {
            Image(systemName: "magnifyingglass")
        })
    }
}

struct View2_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(selectedCar: previewCar)
        .environmentObject(SharedViewData())
        .environmentObject(QuerySharedData())
    }
}
