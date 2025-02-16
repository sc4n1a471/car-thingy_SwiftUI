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
	@State private var verificationCode: String = String()
    
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
				.font(.system(size: 30))
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding(.leading, 20)
			
			DateView(car: selectedCar)
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
					MileageView(onChangeMileageData: websocket.mileage, mileageData: $selectedCar.mileage)
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
            
            Section {
                SpecView(header: "Comment", content: selectedCar.comment)
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
        .alert(sharedViewData.error ?? "sharedViewData.error is a nil??", isPresented: $sharedViewDataBindable.showAlertMapView) {
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
		.alert("2FA", isPresented: $websocket.verificationDialogOpen) {
			SecureField(text: $verificationCode) {}
			
			Button("Cancel") {
				websocket.close()
			}
			
			Button("Submit") {
				websocket.dismissCodeDialog(verificationCode: verificationCode)
			}
		} message: {
			Text("Pls gimme 2fa code")
		}
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
				await websocket.connect(selectedCar.licensePlate, selectedCar)
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
					sharedViewData.showAlert(.mapView, safeErrorMsg)
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
			sharedViewData.showAlert(.mapView, safeCarError)
        }
        
        sharedViewData.isLoading = false
    }
}

	/// https://developer.apple.com/forums/thread/118589
struct BindingMapDetailView: View {
	@State var selectedLicensePlate: String? = "AAMA490"
	
	var body: some View {
		MapDetailView(selectedLicensePlate: $selectedLicensePlate)
			.environment(SharedViewData())
	}
}

#Preview {
	BindingMapDetailView()
}
