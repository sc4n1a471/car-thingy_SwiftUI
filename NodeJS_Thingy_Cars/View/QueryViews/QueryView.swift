//
//  QueryView.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 5/21/23.
//

import SwiftUI

struct QueryView: View {
    @State var requestedLicensePlate: String = ""
    @State var queriedCar: CarQuery?
    @State var error: String?
    @State var showAlert = false
    @State var isQueriedCarLoaded = false
    @State var isLoading = false
    
    @FocusState private var lpTextFieldFocused: Bool
    
    let removableCharacters: Set<Character> = ["-"]
    var textBindingLicensePlate: Binding<String> {
            Binding<String>(
                get: {
                    return requestedLicensePlate
                    
            },
                set: { newString in
                    self.requestedLicensePlate = newString.uppercased()
                    self.requestedLicensePlate.removeAll(where: {
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
