//
//  QuerySheet.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 5/21/23.
//

import SwiftUI

struct QuerySheetView: View {
    @EnvironmentObject var websocket: Websocket
    @StateObject private var viewModel = ViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            List {
                if !viewModel.inspectionsOnly {
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
                        MileageView(onChangeMileageData: websocket.mileage, mileageData: websocket.mileage)
                    }
                    
                    Section {
                        SpecView(header: "Restrictions", contents: websocket.restrictions)
                    }
                    
                    Group {
                        SpecView(header: "Accidents", accidents: websocket.accidents)
                    }
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
                
                if viewModel.enableScrollView {
                    Section {
                        if websocket.inspections.count == 1 {
                            ForEach(websocket.inspections, id: \.self) { inspection in
                                Section {
                                    InspectionView(inspection: inspection)
                                        .frame(width: 391, height: 300)
                                }
                                .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                            }
                        } else {
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(websocket.inspections, id: \.self) { inspection in
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
                    ForEach(websocket.inspections, id: \.self) { inspection in
                        Section {
                            InspectionView(inspection: inspection)
                                .frame(height: 300)
                        }
                        .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                }
            }
            // MARK: Toolbar items
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
//                    close
                    Button(action: {
                        viewModel.setPopover(true)
                    }) {
                        Gauge(value: websocket.percentage, in: 0...100) {}
                            .gaugeStyle(.accessoryCircularCapacity)
                            .tint(.blue)
                            .scaleEffect(0.5)
                            .frame(width: 25, height: 25)
                        
                    }.popover(isPresented: $viewModel.showingPopover) {
                        ForEach(websocket.messages, id: \.self) { message in
                            Text(message)
                        }
                        .presentationCompactAdaptation((.popover))
                        .padding(10)
                    }
                    .isHidden(!websocket.isLoading)
                })
                
                ToolbarItem(placement: .navigationBarTrailing, content: {
//                    closeConnection
//                        .isHidden(!websocket.isLoading)
                    saveCar
                        .isHidden(websocket.isLoading)
                })
            }
            .navigationTitle(websocket.getLP())
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
    
    var closeConnection: some View {
        Button(action: {
            websocket.close()
        }, label: {
            Image(systemName: "xmark.circle.fill")
        })
    }
    
    var saveCar: some View {
        Button(action: {
            Task {
                if await viewModel.saveCar(websocket: websocket) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }, label: {
            Image(systemName: "square.and.arrow.down.fill")
        })
    }
    

}

struct QuerySheetView_Previews: PreviewProvider {
    static var previews: some View {
        QuerySheetView()
            .environmentObject(Websocket(preview: true))
    }
}
