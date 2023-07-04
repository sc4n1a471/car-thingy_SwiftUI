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
    @State var queriedCar: CarQuery
    @State private var isRestrictionsExpanded = false
    @State private var isAccidentsExpanded = false
    
    @State var inspectionsOnly = false
    @State private var enableScrollView = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            List {
                if !inspectionsOnly {
                    Section {
                        SpecView(header: "Brand", content: queriedCar.brand)
                        SpecView(header: "Model", content: queriedCar.model)
                        SpecView(header: "Type Code", content: queriedCar.type_code)
                    }
                    
                    Section {
                        SpecView(header: "Status", content: queriedCar.status)
                        SpecView(header: "First registration", content: queriedCar.first_reg)
                        SpecView(header: "First registration in 🇭🇺", content: queriedCar.first_reg_hun)
                        SpecView(header: "Number of owners", content: String(queriedCar.num_of_owners))
                    }
                    
                    Section {
                        SpecView(header: "Year", content: String(queriedCar.year))
                        SpecView(header: "Engine size", content: String(queriedCar.engine_size), note: "cm3")
                        SpecView(header: "Performance", content: String(queriedCar.performance), note: "HP")
                        SpecView(header: "Fuel type", content: String(queriedCar.fuel_type))
                        SpecView(header: "Gearbox", content: String(queriedCar.gearbox))
                        SpecView(header: "Color", content: String(queriedCar.color))
                    }
                    
                    Section {
                        SpecView(header: "Restrictions", contents: queriedCar.restrictions)
                    }
                    
                    Group {
                        SpecView(header: "Accidents", accidents: queriedCar.accidents)
                    }
                    
                    if let safeMileage = queriedCar.mileage {
                        Section {
                            MileageView(mileageData: safeMileage)
                        }
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
                    close
                })
            }
            .navigationTitle(queriedCar.getLP())
        }
        .onAppear {
            ContentView().haptic(type: .notification)
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
