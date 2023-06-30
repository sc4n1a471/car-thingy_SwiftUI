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
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        Text(queriedCar.brand)
                    } header: {
                        Text(CarQueryData.brand.rawValue)
                    }
                    
                    Section {
                        Text(queriedCar.model)
                    } header: {
                        Text(CarQueryData.model.rawValue)
                    }
                    
                    Section {
                        Text(queriedCar.type_code)
                    } header: {
                        Text(CarQueryData.type_code.rawValue)
                    }
                    
                    Group {
                        Section {
                            Text(queriedCar.status)
                        } header: {
                            Text(CarQueryData.status.rawValue)
                        }

                        Section {
                            Text(queriedCar.first_reg)
                            Text(queriedCar.first_reg_hun)
                        } header: {
                            Text(CarQueryData.first_reg.rawValue)
                        }

                        Section {
                            Text(String(queriedCar.num_of_owners))
                        } header: {
                            Text(CarQueryData.num_of_owners.rawValue)
                        }

                        Section {
                            Text(String(queriedCar.year))
                        } header: {
                            Text(CarQueryData.year.rawValue)
                        }

                        Section {
                            Text(String(queriedCar.engine_size))
                        } header: {
                            Text(CarQueryData.engine_size.rawValue)
                        }

                        Section {
                            Text(String(queriedCar.performance))
                        } header: {
                            Text(CarQueryData.performance.rawValue)
                        }

                        Section {
                            Text(String(queriedCar.fuel_type))
                        } header: {
                            Text(CarQueryData.fuel_type.rawValue)
                        }

                        Section {
                            Text(queriedCar.gearbox)
                        } header: {
                            Text(CarQueryData.gearbox.rawValue)
                        }

                        Section {
                            Text(queriedCar.color)
                        } header: {
                            Text(CarQueryData.color.rawValue)
                        }
                    }
                    
                    Group {
                        Section {
                            DisclosureGroup(CarQueryData.restrictions.rawValue, isExpanded: $isRestrictionsExpanded) {
                                ForEach(queriedCar.restrictions!, id: \.self) { restriction in
                                    Text(restriction)
                                }
                            }

                            DisclosureGroup(CarQueryData.accidents.rawValue, isExpanded: $isAccidentsExpanded) {
                                ForEach(queriedCar.accidents!, id: \.self) { accident in
                                    HStack {
                                        Text(accident.accident_date)
                                        Text(accident.role)
                                    }
                                }
                            }
                        }
                    }
                    
                    if let safeMileage = queriedCar.mileage {
                        MileageView(mileageData: safeMileage)
                    }
                    
                    ///https://www.swiftyplace.com/blog/customise-list-view-appearance-in-swiftui-examples-beyond-the-default-stylings
                    if let safeInspections = queriedCar.inspections {
                        Section {
                            ForEach(safeInspections, id: \.self) { safeInspection in
                                InspectionView(inspection: safeInspection)
                                    .frame(height: 240)
                            }
                            .listStyle(.plain)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(.none)
                    }
                }
                .navigationTitle(queriedCar.getLP())
                
            }
            
            // MARK: Toolbar items
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    close
                })
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
}

struct QuerySheetView_Previews: PreviewProvider {
    static var previews: some View {
        QuerySheetView(queriedCar: testCar)
    }
}
