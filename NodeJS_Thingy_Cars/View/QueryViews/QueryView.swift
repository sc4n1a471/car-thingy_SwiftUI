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
    
    @StateObject var websocket: Websocket = Websocket()
    
    @State private var showingPopover: Bool = false
    @State private var percentage: Double = 0.0
    
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
                .background(!websocket.isLoading ? Color.blue : Color.gray)
                .cornerRadius(10)
                .disabled(websocket.isLoading)
                
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
                .background(!websocket.isLoading ? Color.blue : Color.gray)
                .cornerRadius(10)
                .disabled(websocket.isLoading)
            }
            .padding()
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing, content: {
                
                    Button(action: {
                        showingPopover = true
                    }) {
                        Gauge(value: websocket.percentage, in: 0...17) {}
                            .gaugeStyle(.accessoryCircularCapacity)
                            .tint(.blue)
                            .scaleEffect(0.5)
                            .frame(width: 25, height: 25)
                        
                    }.popover(isPresented: $showingPopover) {
                        ForEach(websocket.messages, id: \.id) { message in
                            if let safeValue = message.response.value {
                                Text(safeValue)
                            }
                        }
                        .presentationCompactAdaptation((.popover))
                    }
                    .isHidden(!websocket.isLoading)
                    
                        
                    
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
                .presentationDetents([.medium, .large])
        }
    }
    
    func queryCarButton(requestedCar: String) async {
        websocket.connect()
        websocket.sendMessage(requestedCar)
    }
}

struct Message: Identifiable {
    var id = UUID()
    var response: WebhookResponse
}

class Websocket: ObservableObject {
    @Published var messages = [Message]()
    @Published var percentage = Double()
    @Published var isLoading = Bool()
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var counter = 0
    
    init() {}
    
    func connect() {
        guard let url = URL(string: "ws://10.11.12.250:3001/") else { return }
        let request = URLRequest(url: url)

        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        receiveMessage()
        print("Connected")
        self.isLoading.toggle()
    }
    
    private func receiveMessage() {
        print("Listening... (\(self.counter))")
        counter += 1
        webSocketTask?.receive(completionHandler: { result in
            switch result {
            case .failure(let error):
                print("Received error: \(error.localizedDescription)")
                self.close()
                return
            case .success(let message):
                switch message {
                case .string(let text):
                    
                    let jsonData = Data(text.utf8)
                    
                    let (safeResponse, safeError) = initWebhookResponse(dataCuccli: jsonData)
                    
                    if let safeResponse {
                        if safeResponse.status == "success" {
                            self.close()
                            return
                        } else {
                            self.messages.append(Message(response: safeResponse))
                            self.percentage = safeResponse.percentage
//                            self.ping()
                        }
                    }
                    if let safeError {
                        print("error: \(safeError)")
                    }
                case .data(let data):
                    // Handle binary data
                    print(data)
                    
                    break
                @unknown default:
                    break
                }
            }
            
            if self.counter < 100 {
                self.receiveMessage()
            } else {
                print("Forced close")
                self.close()
            }
        })
    }
    
    func sendMessage(_ message: String) {
        guard let data = message.data(using: .utf8) else { return }
        webSocketTask?.send(.string(message)) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func close() {
        webSocketTask?.cancel(with: .goingAway, reason: "Query ended".data(using: .utf8))
        print("Disconnected")
        self.percentage = 0.0
        self.isLoading.toggle()
    }
    
    func ping() {
        webSocketTask?.sendPing { error in
            if let safeError = error {
                print("Ping error: \(error?.localizedDescription)")
            }
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
