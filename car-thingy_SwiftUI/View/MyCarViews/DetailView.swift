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
    @Environment(\.presentationMode) var presentationMode
	
	@Namespace var animation

    @State var selectedCar: Car
    @State var region: MKCoordinateRegion
    @State private var enableScrollView: Bool = true
    	
	@State private var verificationCode: String = String()
    
    let columns = [
        GridItem(.flexible(minimum: 100, maximum: 200)),
        GridItem(.flexible(minimum: 100, maximum: 200))
    ]
    
    var body: some View {
		// required because can't use environment as binding
        @Bindable var sharedViewDataBindable = sharedViewData
        
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
                        if sharedViewData.websocket.isLoading {
                            openQuerySheet
                        } else {
                            queryButton
                        }
                    })
                }
            }
            .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            if selectedCar.brand != nil {
                Section {
                    SpecView(header: "Brand", content: selectedCar.brand)
                    SpecView(header: "Model", content: selectedCar.model)
                    SpecView(header: "Type Code", content: selectedCar.typeCode)
                }
                
                Section {
                    SpecView(header: "Status", content: selectedCar.status)
                    SpecView(header: "First registration", content: selectedCar.firstReg)
                    SpecView(header: "First registration in 🇭🇺", content: selectedCar.firstRegHun)
                    SpecView(header: "Number of owners", content: String(selectedCar.numOfOwners ?? 99))
                }
                
                Section {
                    SpecView(header: "Year", content: String(selectedCar.year ?? 1970))
                    SpecView(header: "Engine size", content: String(selectedCar.engineSize ?? 9999), note: "cm3")
                    SpecView(header: "Performance", content: String(selectedCar.performance ?? 999), note: "HP")
                    SpecView(header: "Fuel type", content: selectedCar.fuelType)
                    SpecView(header: "Gearbox", content: selectedCar.gearbox)
                    SpecView(header: "Color", content: selectedCar.color)
                }
                
                Section {
                    MileageView(onChangeMileageData: sharedViewData.websocket.mileage, mileageData: $selectedCar.mileage)
                }
                
                Section {
                    SpecView(header: "Restrictions", restrictions: selectedCar.restrictions)
                }
                
                Section {
                    SpecView(header: "Accidents", accidents: selectedCar.accidents)
                }
                
                Section {
                    InspectionsView(inspections: selectedCar.inspections ?? [Inspection()])
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
            
            Section {
                SpecView(header: "Comment", content: selectedCar.comment)
            }
            
            Section {
                deleteButton
            }
            .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .navigationTitle(selectedCar.getLP())
		.navigationBarTitleDisplayMode(.large)
		
		// MARK: Sheets
        .sheet(isPresented: $sharedViewDataBindable.isEditCarPresented, onDismiss: {
            Task {
                await loadSelectedCar()
            }
        }) {
            NewCar(isUpload: false)
        }
//        .sheet(isPresented: $sharedViewDataBindable.websocket.dataSheetOpened, onDismiss: {
//            Task {
//                sharedViewData.websocket.dismissSheet()
//                await loadSelectedCar()
//            }
//        }) {
//            QuerySheetView()
//                .presentationDetents([.medium, .large])
//        }
		
		// MARK: Alerts
        .alert(sharedViewData.websocket.error, isPresented: $sharedViewDataBindable.websocket.isAlert, actions: {
            Button("sharedViewData.websocket got it") {
                sharedViewData.websocket.disableAlert()
                print("sharedViewData.websocket alert confirmed")
            }
        })
		.alert(sharedViewData.error ?? "sharedViewData.error is a nil??", isPresented: $sharedViewDataBindable.showAlertDetailView) {
			Button("Got it") {
				print("alert confirmed")
			}
		}
		
		// MARK: Other
        .onAppear() {
            sharedViewData.existingCar = selectedCar
            sharedViewData.region = region
            Task {
                await loadSelectedCar()
            }
        }
		.toolbar(content: {
			ToolbarItem(placement: .topBarTrailing, content: {
				DateView(car: selectedCar, mapView: false)
					.frame(maxWidth: .infinity, alignment: .trailing)
			})
		})
    }
    
    // MARK: Query sheet button
    var openQuerySheet: some View {
        Button(action: {
            sharedViewData.websocket.openSheet()
        }) {
            Gauge(value: sharedViewData.websocket.percentage, in: 0...100) {}
                .gaugeStyle(.accessoryCircularCapacity)
                .tint(.blue)
                .scaleEffect(0.5)
                .frame(width: 25, height: 25)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(.blue)
        .frame(height: 50)
    }
    
	// MARK: Edit button
    var editButton: some View {
        Button (action: {
            sharedViewData.isEditCarPresented.toggle()
        }, label: {
            Image(systemName: "pencil")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
        .buttonStyle(.bordered)
        .frame(height: 50)
    }
    
	// MARK: Query button
    var queryButton: some View {
        Button(action: {
            Task {
				sharedViewData.showMiniQueryView = true
				await sharedViewData.websocket.connect(selectedCar.licensePlate, selectedCar)
            }
        }, label: {
            Image(systemName: "magnifyingglass")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
        .buttonStyle(.borderedProminent)
        .frame(height: 50)
    }
    
	// MARK: Delete button
    var deleteButton: some View {
        Button(action: {
            Task {
				sharedViewData.isLoading = true
                let (successMsg, errorMsg) = try await deleteCar(licensePlate: selectedCar.licensePlate)
                
                if successMsg != nil {
                    presentationMode.wrappedValue.dismiss()
					await sharedViewData.loadViewData()
                }
                
                if let safeErrorMsg = errorMsg {
					sharedViewData.showAlert(.detailView, safeErrorMsg)
                }
				sharedViewData.isLoading = false
            }
        }, label: {
            Image(systemName: "trash")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
        .buttonStyle(.bordered)
        .frame(height: 50)
        .tint(.red)
        .disabled(sharedViewData.isLoading)
    }
    
    // MARK: Functions
    func loadSelectedCar() async {
        sharedViewData.isLoading = true
        let (safeCar, safeCarError) = await loadCar(license_plate: sharedViewData.existingCar.licensePlate)
        if let safeCar {
            sharedViewData.existingCar = safeCar[0]
            selectedCar = sharedViewData.existingCar
        }
        
        if let safeCarError {
			sharedViewData.showAlert(.detailView, safeCarError)
        }
        
        sharedViewData.isLoading = false
    }
}

#Preview {
	DetailView(
		selectedCar: previewCar,
		region: previewCar.getLocation()
	)
        .environment(SharedViewData())
}
