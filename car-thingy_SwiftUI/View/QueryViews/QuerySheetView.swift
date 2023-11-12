//
//  QuerySheet.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 5/21/23.
//

import SwiftUI

struct QuerySheetView: View {
    @Bindable var websocket: Websocket
    @State private var viewModel = ViewModel()
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
                        MileageView(onChangeMileageData: websocket.mileage, mileageData: $websocket.mileage)
                    }
                    
                    Section {
                        SpecView(header: "Restrictions", contents: websocket.restrictions)
                    }
                    
                    Group {
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
                
                ToolbarItem(placement: .navigationBarLeading, content: {
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
                    saveCar
                        .disabled(websocket.isLoading)
                })
                
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    closeConnection
                        .disabled(!websocket.isLoading)
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
        .buttonStyle(.bordered)
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
        .buttonStyle(.borderedProminent)
    }
    

}

#Preview {
    QuerySheetView(websocket: Websocket(preview: true))
}
