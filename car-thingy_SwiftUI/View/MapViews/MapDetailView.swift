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
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedCar: Car = Car()
    @Binding var selectedLicensePlate: String?
    @State private var enableScrollView: Bool = true
    @State private var websocket: Websocket = Websocket()
    
    let columns = [
        GridItem(.flexible(minimum: 100, maximum: 200)),
        GridItem(.flexible(minimum: 100, maximum: 200)),
        GridItem(.flexible(minimum: 100, maximum: 200))
    ]
	let columns2 = [
		GridItem(.flexible(minimum: 100, maximum: 200)),
		GridItem(.flexible(minimum: 100, maximum: 200))
	]
    
    var body: some View {
            // required because can't use environment as binding
        @Bindable var sharedViewDataBindable = sharedViewData
        
		LazyVGrid(columns: columns2, content: {
			Text(selectedCar.getLP())
				.fontWeight(.bold)
				.font(.system(size: 35))
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding(.leading, 20)
			
			DateView(licensePlate: selectedCar.license_plate)
				.frame(maxWidth: .infinity, alignment: .trailing)
				.padding(.trailing, 20)
				.font(.system(size: 17))
				.presentationBackground(.ultraThinMaterial)
		})
		.padding(.top, 20)
                
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
                        deleteButton
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
                
                if let safeInspections = selectedCar.inspections {
                    InspectionsView(inspections: safeInspections)
                }
            }
            
            Section {
                SpecView(header: "Comment", content: selectedCar.license_plate.comment)
            }
        }
        .onAppear() {
            Task {
                await loadSelectedCar()
            }
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
                await websocket.dismissSheet()
                await loadSelectedCar()
            }
        }) {
            QuerySheetView(websocket: websocket)
                .presentationDetents([.medium, .large])
        }
        .alert(sharedViewData.error ?? "sharedViewData.error is a nil??", isPresented: $sharedViewDataBindable.showAlert) {
            Button("Got it") {
                print("alert confirmed")
            }
        }
        .alert(websocket.error, isPresented: $websocket.isAlert, actions: {
            Button("Websocket got it") {
                websocket.disableAlert()
                print("websocket alert confirmed")
            }
        })
        .background(.clear)
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
        Button(action: {
            Task {
                let (successMsg, errorMsg) = try await deleteCar(licensePlate: selectedLicensePlate!)
                
				if successMsg != nil {
                    withAnimation(.snappy) {
                        selectedLicensePlate = nil
                    }
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
    }
    
    private func loadSelectedCar() async {
        sharedViewData.isLoading = true
        let (safeCar, safeCarError) = await loadCar(license_plate: selectedLicensePlate!)
        if let safeCar {
            selectedCar = safeCar[0]
            sharedViewData.existingCar = selectedCar
            sharedViewData.haptic(type: .notification)
        }
        
        if let safeCarError {
            sharedViewData.showAlert(errorMsg: safeCarError)
        }
        
        sharedViewData.isLoading = false
    }
}

	/// https://developer.apple.com/forums/thread/118589
struct BindingMapDetailView: View {
	@State var selectedLicensePlate: String? = "MIA192"
	
	var body: some View {
		MapDetailView(selectedLicensePlate: $selectedLicensePlate)
			.environment(SharedViewData())
	}
}

#Preview {
	BindingMapDetailView()
}
