//
//  QueryView.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 5/21/23.
//

import SwiftUI

struct QueryView: View {
    @EnvironmentObject var querySharedData: QuerySharedData
    
    @FocusState private var lpTextFieldFocused: Bool
    
    let removableCharacters: Set<Character> = ["-"]
    var textBindingLicensePlate: Binding<String> {
            Binding<String>(
                get: {
                    return querySharedData.requestedLicensePlate
                    
            },
                set: { newString in
                    querySharedData.requestedLicensePlate = newString.uppercased()
                    querySharedData.requestedLicensePlate.removeAll(where: {
                        removableCharacters.contains($0)
                    })
            })
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 50) {
                Section {
                    TextField("Enter requested license plate", text: textBindingLicensePlate)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .frame(maxWidth: 400)
                        .focused($lpTextFieldFocused)
                }
                Button {
                    Task {
                        lpTextFieldFocused = false
                        await queryCarButton(requestedCar: querySharedData.requestedLicensePlate)
                    }
                } label: {
                    Text("Request")
                        .frame(maxWidth: 200, maxHeight: 50)
                }
                .buttonStyle(.borderless)
                .foregroundColor(.white)
                .background(!querySharedData.isLoading ? Color.blue : Color.gray)
                .cornerRadius(10)
                .disabled(querySharedData.isLoading)
                
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
                .background(!querySharedData.isLoading ? Color.blue : Color.gray)
                .cornerRadius(10)
                .disabled(querySharedData.isLoading)
            }
            .padding()
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing, content: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .isHidden(!querySharedData.isLoading)
                    
                    Link(destination:
                            URL(string:"https://magyarorszag.hu/jszp_szuf")!
                    ) {
                        Image(systemName: "link")
                    }
                })
            }
            .navigationTitle("Car Query")
        }
        .alert(querySharedData.error ?? "No error message??", isPresented: $querySharedData.showAlert, actions: {
            Button("Got it") {
                print("alert confirmed")
            }
        })
        .sheet(isPresented: $querySharedData.isQueriedCarLoaded, onDismiss: {
            Task {}
        }) {
            QuerySheetView(queriedCar: querySharedData.queriedCar ?? testCar)
        }
    }
    
    func queryCarButton(requestedCar: String) async {
        querySharedData.isLoading.toggle()
        
        let (safeCar, safeCarError) = await queryCar(license_plate: requestedCar)
        if let safeCar {
            querySharedData.queriedCar = safeCar
            querySharedData.isQueriedCarLoaded.toggle()
            print(querySharedData.isQueriedCarLoaded)
        }
        
        if let safeCarError {
            MyCarsView().haptic(type: .error)
            querySharedData.error = safeCarError
            querySharedData.showAlert = true
        }
        querySharedData.isLoading.toggle()
    }
}

struct QueryView_Previews: PreviewProvider {
    static var previews: some View {
        QueryView()
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
            .previewDisplayName("iPhone SE")
            .environmentObject(QuerySharedData())
        QueryView()
            .previewDevice(PreviewDevice(rawValue: "My Mac (Mac Catalyst)"))
            .previewDisplayName("Mac Catalyst")
            .environmentObject(QuerySharedData())
    }
}
