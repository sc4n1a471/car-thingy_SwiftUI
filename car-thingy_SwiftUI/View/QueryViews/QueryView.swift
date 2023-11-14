    //
    //  QueryView.swift
    //  NodeJS_Thingy_Cars
    //
    //  Created by Martin Terhes on 5/21/23.
    //

import SwiftUI

struct QueryView: View {
    @FocusState private var lpTextFieldFocused: Bool
    
    @State private var viewModel = ViewModel()
    @State var websocket: Websocket = Websocket()
    @State private var requestedLicensePlate: String = String()
    
    let removableCharacters: Set<Character> = ["-"]
    var textBindingLicensePlate: Binding<String> {
        Binding<String>(
            get: {
                return requestedLicensePlate
                
            },
            set: { newString in
                requestedLicensePlate = newString.uppercased()
                requestedLicensePlate.removeAll(where: {
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
                        await websocket.connect(requestedLicensePlate)
                    }
                } label: {
                    Text("Request")
                        .frame(maxWidth: 200, maxHeight: 50)
                }
                .buttonStyle(.borderless)
                .foregroundColor(.white)
                .background(!websocket.isLoading ? Color.blue : Color.gray)
                .cornerRadius(10)
                .disabled(websocket.isLoading)
                
                Button {
                    Task {
                        await websocket.connect("test111")
                    }
                } label: {
                    Text("Test Request")
                        .frame(maxWidth: 200, maxHeight: 50)
                }
                .buttonStyle(.borderless)
                .foregroundColor(.white)
                .background(!websocket.isLoading ? Color.blue : Color.gray)
                .cornerRadius(10)
                .disabled(websocket.isLoading)
            }
            .padding()
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing, content: {
                    
                    Button(action: {
                        websocket.openSheet()
                    }) {
                        Gauge(value: websocket.percentage, in: 0...100) {}
                            .gaugeStyle(.accessoryCircularCapacity)
                            .tint(.blue)
                            .scaleEffect(0.5)
                            .frame(width: 25, height: 25)
                        
                    }
                    .isHidden(!websocket.isLoading)
                })
                
                ToolbarItemGroup(placement: .navigationBarLeading, content: {
                    Link(destination:
                            URL(string:"https://magyarorszag.hu/jszp_szuf")!
                    ) {
                        Image(systemName: "link")
                    }
                    Button(action: {
                        websocket.openSheet()
                    }) {
                        Image(systemName: "tray")
                    }
                    .isHidden(!websocket.isSuccess)
                })
            }
            .navigationTitle("Car Query")
        }
        .alert(websocket.error, isPresented: $websocket.showAlert, actions: {
            Button("Websocket got it") {
                websocket.disableAlert()
                print("websocket alert confirmed")
            }
        })
        .sheet(isPresented: $websocket.dataSheetOpened, onDismiss: {
            Task {
                websocket.dismissSheet()
            }
        }) {
            QuerySheetView(websocket: websocket, knownCarQuery: false)
                .presentationDetents([.medium, .large])
        }
    }
}

struct QueryView_Previews: PreviewProvider {
    static var previews: some View {
        QueryView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
            .previewDisplayName("iPhone 13 Pro")
//        QueryView()
//            .previewDevice(PreviewDevice(rawValue: "My Mac (Mac Catalyst)"))
//            .previewDisplayName("Mac Catalyst")
    }
}
