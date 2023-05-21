//
//  QueryView.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 5/21/23.
//

import SwiftUI

var testCar: CarQuery = CarQuery(accidents: [:], brand: "yas", color: "Black", engine_size: 5000, first_reg: "yas", first_reg_hun: "yas", fuel_type: "yas", gearbox: "Automatic", inspections: [CarQueryInspection(images: [], inspection: "yas")], license_plate: "AAAA111", mileage: [Mileage(mileage: 100, mileageDate: "2020.01.01.")], model: "yas", num_of_owners: 5, performance: 400, restrictions: [], status: "yas", type_code: "yas", year: 2005)

struct QueryView: View {
    @State var requestedLicensePlate: String = "test111"
    @State var returnedCarQuery: ReturnCarQuery = ReturnCarQuery()
    @State var showAlert = false
    @State var isQueriedCarLoaded = false
    @State var isLoading = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 50) {
                Section {
                    TextField("Enter requested license plate", text: $requestedLicensePlate)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                Button("Request") {
                    Task {
                        await queryCarButton(requestedCar: $requestedLicensePlate.wrappedValue)
                    }
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: 200)
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
                })
            }
        }
        .alert(returnedCarQuery.error, isPresented: $showAlert, actions: {
            Button("Got it") {
                print("alert confirmed")
            }
        })
        .sheet(isPresented: $isQueriedCarLoaded, onDismiss: {
            Task {}
        }) {
            QuerySheetView(queriedCar: returnedCarQuery.queriedCar ?? testCar)
        }
        
    }
    
    func queryCarButton(requestedCar: String) async {
        isLoading.toggle()
        print(requestedCar)
//        sleep(2)
        returnedCarQuery = await queryCar(license_plate: requestedCar)
        if (returnedCarQuery.error != "DEFAULT_VALUE") {
            showAlert = true
        } else {
            isQueriedCarLoaded.toggle()
        }
        isLoading.toggle()
    }
}

struct QueryView_Previews: PreviewProvider {
    static var previews: some View {
        QueryView()
    }
}
