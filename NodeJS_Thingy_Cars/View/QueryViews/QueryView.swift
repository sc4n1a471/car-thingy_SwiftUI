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
    @StateObject private var viewModel = ViewModel()
    @StateObject var websocket: Websocket = Websocket()
    
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
                        await websocket.connect(querySharedData.requestedLicensePlate)
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
        .alert(querySharedData.error ?? "No error message??", isPresented: $querySharedData.showAlert, actions: {
            Button("Got it") {
                print("alert confirmed")
            }
        })
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
            QuerySheetView()
                .presentationDetents([.medium, .large])
                .environmentObject(websocket)
        }
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
