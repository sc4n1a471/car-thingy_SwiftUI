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
    
    @ObservedObject var websocket: Websocket = Websocket()
    
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
        
        websocket.connect()
        websocket.sendMessage(requestedCar)
        
//        let (safeCar, safeCarError) = await queryCar(license_plate: requestedCar)
//        if let safeCar {
//            querySharedData.queriedCar = safeCar
//            querySharedData.isQueriedCarLoaded.toggle()
//            print(querySharedData.isQueriedCarLoaded)
//        }
//
//        if let safeCarError {
//            MyCarsView().haptic(type: .error)
//            querySharedData.error = safeCarError
//            querySharedData.showAlert = true
//        }
        querySharedData.isLoading.toggle()
    }
}

class Websocket: ObservableObject {
    @Published var messages = String()
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var counter = 0
    
    init() {
//        print("Connected")
//        self.connect()
//        ping()
    }
    
    func connect() {
        guard let url = URL(string: "ws://127.0.0.1:3001/") else { return }
        let request = URLRequest(url: url)
//        let session = URLSession(
//            configuration: .default,
//            delegate: self,
//            delegateQueue: OperationQueue()
//        )
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        receiveMessage()
        print("Connected")
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
//                    self.messages.append(text)
                    
                    let jsonData = Data(text.utf8)
                    
                    let (safeCar, safeMessage, safeCarError) = initCarQuery(dataCuccli: jsonData)
                    
                    if let safeCar {
                        print("Received car successfully")
                        self.close()
                        return
                    }
                    if let safeMessage {
                        print("Message")
                        self.ping()
                    }
                    if let safeCarError {
                        print("error")
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
    }
    
    func ping() {
        webSocketTask?.sendPing { error in
            if let safeError = error {
                print("Ping error: \(error?.localizedDescription)")
            }
        }
    }
}

//class WebSocketClass {
//    let session = URLSession(
//        configuration: .default,
//        delegate: self,
//        delegateQueue: OperationQueue()
//    )
//
//    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
//        print("open")
//    }
//
//    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
//        print("close")
//    }
//}

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
