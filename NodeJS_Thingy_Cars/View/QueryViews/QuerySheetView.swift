//
//  QuerySheet.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 5/21/23.
//

import SwiftUI

enum CarQueryData: String {
    case accidents = "Accidents"
    case brand = "Brand"
    case color = "Color"
    case engine_size = "Engine Size (cm3)"
    case first_reg = "First Registration Date / in Hungary"
    case first_reg_hun = "First Registration Date in Hungary"
    case fuel_type = "Fuel Type"
    case gearbox = "Gearbox"
    case inspections = "Inspections"
    case license_plate = "License Plate"
    case mileage = "Mileage"
    case model = "Model"
    case num_of_owners = "Number of owners"
    case performance = "Performance (HP)"
    case restrictions = "Restrictions"
    case status = "Status"
    case type_code = "Type Code"
    case year = "Year"
}

struct QuerySheetView: View {
    @EnvironmentObject var websocket: Websocket
    
    @State var queriedCar: CarQuery
    @State private var isRestrictionsExpanded = false
    @State private var isAccidentsExpanded = false
    @State private var showingPopover = false
    
    @State var inspectionsOnly = false
    @State private var enableScrollView = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            List {
                if !inspectionsOnly {
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
                        SpecView(header: "Year", content: websocket.year)
                        SpecView(header: "Engine size", content: String(websocket.engine_size), note: "cm3")
                        SpecView(header: "Performance", content: String(websocket.performance), note: "HP")
                        SpecView(header: "Fuel type", content: String(websocket.fuel_type))
                        SpecView(header: "Gearbox", content: String(websocket.gearbox))
                        SpecView(header: "Color", content: String(websocket.color))
                    }
                    
                    Section {
                        SpecView(header: "Restrictions", contents: websocket.restrictions)
                    }
                    
                    Group {
                        SpecView(header: "Accidents", accidents: websocket.accidents)
                    }
                    
                    Section {
                        MileageView(onChangeMileageData: websocket.mileage, mileageData: websocket.mileage)
                    }
                }
                
                ///https://www.swiftyplace.com/blog/customise-list-view-appearance-in-swiftui-examples-beyond-the-default-stylings
                if let safeInspections = queriedCar.inspections {
                    if enableScrollView {
                        Section {
                            if safeInspections.count == 1 {
                                ForEach(safeInspections, id: \.self) { safeInspection in
                                    Section {
                                        InspectionView(inspection: safeInspection)
                                            .frame(width: 391, height: 300)
                                    }
                                    .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                                }
                            } else {
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(safeInspections, id: \.self) { safeInspection in
                                            Section {
                                                InspectionView(inspection: safeInspection)
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
                        ForEach(safeInspections, id: \.self) { safeInspection in
                            Section {
                                InspectionView(inspection: safeInspection)
                                    .frame(height: 300)
                            }
                            .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        }
                    }
                }
            }
            // MARK: Toolbar items
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
//                    close
                    Button(action: {
                        showingPopover = true
                    }) {
                        Gauge(value: websocket.percentage, in: 0...17) {}
                            .gaugeStyle(.accessoryCircularCapacity)
                            .tint(.blue)
                            .scaleEffect(0.5)
                            .frame(width: 25, height: 25)
                        
                    }.popover(isPresented: $showingPopover) {
                        ForEach(websocket.messages, id: \.id) { message in
                            if let safeValue = message.response.value {
//                                Text(safeValue)
                            }
                        }
                        .presentationCompactAdaptation((.popover))
                    }
                    .isHidden(!websocket.isLoading)
                })
            }
            .navigationTitle(queriedCar.getLP())
        }
        .onAppear {
            MyCarsView().haptic(type: .notification)
        }
    }
    
    var close: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Close")
        })
    }
}

struct QuerySheetView_Previews: PreviewProvider {
    static var previews: some View {
        QuerySheetView(queriedCar: testCar)
    }
}
