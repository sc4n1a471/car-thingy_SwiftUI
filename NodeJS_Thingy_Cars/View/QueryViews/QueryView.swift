//
//  QueryView.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 5/21/23.
//

import SwiftUI

var testCar: CarQuery = CarQuery(
    accidents: [
        Accident(accident_date: "2020.01.01", role: "Károkozó")
    ],
    brand: "yas",
    color: "Black",
    engine_size: 5000,
    first_reg: "yas",
    first_reg_hun: "yas",
    fuel_type: "yas",
    gearbox: "Automatic",
    inspections: [
        Inspection(images: [], name: "yas")
    ],
    license_plate: "AAAA111",
    mileage: [
        Mileage(mileage: 127973, mileageDate: "2012.10.17."),
        Mileage(mileage: 147050, mileageDate: "2013.06.18."),
        Mileage(mileage: 249246, mileageDate: "2014.09.25."),
        Mileage(mileage: 260900, mileageDate: "2017.04.25."),
        Mileage(mileage: 302876, mileageDate: "2019.04.26."),
        Mileage(mileage: 355278, mileageDate: "2021.04.13."),
        Mileage(mileage: 456294, mileageDate: "2023.03.20.")
    ],
    model: "yas",
    num_of_owners: 5,
    performance: 400,
    restrictions: [
        "1", "2", "3"
    ],
    status: "yas",
    type_code: "yas",
    year: 2005
)

struct QueryView: View {
    @State var requestedLicensePlate: String = ""
    @State var queriedCar: CarQuery?
    @State var error: String?
    @State var showAlert = false
    @State var isQueriedCarLoaded = false
    @State var isLoading = false
    
    @FocusState private var lpTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 50) {
                Section {
                    TextField("Enter requested license plate", text: $requestedLicensePlate)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .frame(maxWidth: 400)
                        .focused($lpTextFieldFocused)
                }
                Button {
                    Task {
                        lpTextFieldFocused = false
                        await queryCarButton(requestedCar: $requestedLicensePlate.wrappedValue)
                    }
                } label: {
                    Text("Request")
                        .frame(maxWidth: 200, maxHeight: 50)
                }
                .buttonStyle(.borderless)
                .foregroundColor(.white)
                .background(!isLoading ? Color.blue : Color.gray)
                .cornerRadius(10)
                .disabled(isLoading)
                
                Button {
                    Task {
                        await queryCarButton(requestedCar: "test111")
                    }
                } label: {
                    Text("Test Request")
                        .frame(maxWidth: 200, maxHeight: 50)
                }
                .buttonStyle(.borderless)
                .foregroundColor(.white)
                .background(!isLoading ? Color.blue : Color.gray)
                .cornerRadius(10)
                .disabled(isLoading)
            }
            .padding()
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing, content: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .isHidden(!isLoading)
                    
                    Link(destination:
                            URL(string:"https://magyarorszag.hu/jszp_szuf")!
                    ) {
                        Image(systemName: "link")
                    }
                })
            }
            .navigationTitle("Car Query")
        }
        .alert(error ?? "No error message??", isPresented: $showAlert, actions: {
            Button("Got it") {
                print("alert confirmed")
            }
        })
        .sheet(isPresented: $isQueriedCarLoaded, onDismiss: {
            Task {}
        }) {
//            Button("Dismiss", action: { isQueriedCarLoaded.toggle() })
//                .buttonStyle(BorderedButtonStyle())
//                .padding()
            QuerySheetView(queriedCar: queriedCar ?? testCar)
        }
    }
    
    func queryCarButton(requestedCar: String) async {
        isLoading.toggle()
        
        let (safeCar, safeCarError) = await queryCar(license_plate: requestedCar)
        if let safeCar {
            queriedCar = safeCar
            isQueriedCarLoaded.toggle()
        }
        
        if let safeCarError {
            error = safeCarError
            showAlert = true
        }
        isLoading.toggle()
    }
}

struct QueryView_Previews: PreviewProvider {
    static var previews: some View {
        QueryView()
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
            .previewDisplayName("iPhone SE")
        QueryView()
            .previewDevice(PreviewDevice(rawValue: "My Mac (Mac Catalyst)"))
            .previewDisplayName("Mac Catalyst")
    }
}
