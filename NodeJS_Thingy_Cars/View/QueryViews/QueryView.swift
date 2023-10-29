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
                        websocket.openSheet()
                    }) {
                        Gauge(value: websocket.percentage, in: 0...100) {}
                            .gaugeStyle(.accessoryCircularCapacity)
                            .tint(.blue)
                            .scaleEffect(0.5)
                            .frame(width: 25, height: 25)
                        
                    }
//                    .popover(isPresented: $showingPopover) {
//                        ForEach(websocket.messages, id: \.self) { message in
//                            Text(message)
//                        }
//                        .presentationCompactAdaptation((.popover))
//                    }
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
            QuerySheetView(queriedCar: querySharedData.queriedCar ?? testCar)
                .presentationDetents([.medium, .large])
                .environmentObject(websocket)
        }
    }
    
    func queryCarButton(requestedCar: String) async {
        await websocket.connect(requestedCar)
        print("success?")
//        websocket.sendMessage(requestedCar)
    }
}

@MainActor class Websocket: ObservableObject {
    @Published var messages = [String]()
    @Published var percentage = Double()
    @Published var isLoading = Bool()
    @Published var isSuccess = false
    @Published var dataSheetOpened = false
    @Published var error = String()
    @Published var showAlert = false
    
    @Published var license_plate = String()
    
        // TODO: Maybe create a class for these attributes and set individual setters for them
    @Published var brand = String()
    @Published var color = String()
    @Published var engine_size = Int()
    @Published var first_reg = String()
    @Published var first_reg_hun = String()
    @Published var fuel_type = String()
    @Published var gearbox = String()
    @Published var model = String()
    @Published var num_of_owners = Int()
    @Published var performance = Int()
    @Published var status = String()
    @Published var type_code = String()
    @Published var year = Int()
    
    @Published var accidents = [Accident()]
    @Published var restrictions = [String()]
    @Published var mileage = [Mileage()]
    @Published var inspections = [Inspection()]
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var counter = 0
    
    init() {}
    
    func getLP() -> String {
        var formattedLicensePlate = self.license_plate.uppercased()
        
        if (formattedLicensePlate != "ERROR") {
            var numOfLetters = 0
            
            for char in formattedLicensePlate {
                if (char.isLetter) {
                    numOfLetters += 1
                }
            }
            
            formattedLicensePlate.insert(contentsOf: "-", at: formattedLicensePlate.index(formattedLicensePlate.startIndex, offsetBy: numOfLetters))
            
                // if it's the new license plate
            if (self.license_plate.count > 6) {
                formattedLicensePlate.insert(contentsOf: " ", at: formattedLicensePlate.index(formattedLicensePlate.startIndex, offsetBy: 2))
            }
        }
        
        return formattedLicensePlate
    }
    
    func openSheet() {
        self.dataSheetOpened = true
    }
    
    func dismissSheet() {
        self.dataSheetOpened = false
    }
    
    func setLoading(_ newStatus: Bool) {
        self.isLoading = newStatus
    }
    
    func setValues(_ value: WebsocketResponseType, key: CarDataType = .brand) {
        switch value {
            case .accidents(let accidents):
                self.accidents = accidents
            case .restrictions(let restrictions):
                self.restrictions = restrictions
            case .mileage(let mileage):
                self.mileage = mileage
            case .stringValue(let stringValue):
                switch key {
                    case CarDataType.brand:
                        self.brand = stringValue
                        break
                    case CarDataType.color:
                        self.color = stringValue
                        break
                    case CarDataType.first_reg:
                        self.first_reg = stringValue
                        break
                    case CarDataType.first_reg_hun:
                        self.first_reg_hun = stringValue
                        break
                    case CarDataType.fuel_type:
                        self.fuel_type = stringValue
                        break
                    case CarDataType.gearbox:
                        self.gearbox = stringValue
                        break
                    case CarDataType.model:
                        self.model = stringValue
                        break
                    case CarDataType.status:
                        self.status = stringValue
                        break
                    case CarDataType.type_code:
                        self.type_code = stringValue
                        break
                    default:
                        break
                }
            case .intValue(let intValue):
                switch key {
                    case CarDataType.engine_size:
                        self.engine_size = intValue
                        break
                    case CarDataType.num_of_owners:
                        self.num_of_owners = intValue
                        break
                    case CarDataType.performance:
                        self.performance = intValue
                        break
                    case CarDataType.year:
                        self.year = intValue
                        break
                    default:
                        break
                }
            case .message(let message):
                self.messages.append(message)
                print("Message: \(message)")
                break
            default:
                print("default value: \(value)")
                break
        }
    }
    
    func clearValues() {
        self.brand = String()
        self.color = String()
        self.first_reg = String()
        self.first_reg_hun = String()
        self.fuel_type = String()
        self.gearbox = String()
        self.model = String()
        self.status = String()
        self.type_code = String()
        
        self.num_of_owners = Int()
        self.performance = Int()
        self.engine_size = Int()
        self.year = Int()
        
        self.accidents = [Accident()]
        self.restrictions = [String()]
        self.mileage = [Mileage()]
        self.inspections = [Inspection()]
        
        self.messages = [String()]
    }
    
    func getInspections(_ licensePlate: String) async {
        let (inspections, error) = await loadInspections(license_plate: licensePlate)
        if let safeInspections = inspections {
            self.inspections = safeInspections
        }
        if let safeError = error {
            self.enableAlert(error: safeError)
        }
    }
    
    func enableAlert(error: String) {
        self.error = error
        self.showAlert = true
    }
    
    func disableAlert() {
        self.error = String()
        self.showAlert = false
    }

    func connect(_ requestedCar: String) async {
        self.setLoading(true)
        guard let url = URL(string: getURLasString(whichUrl: "carWebsocket")) else { return }
        let request = URLRequest(url: url)
        
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        self.counter = 0
        self.clearValues()
        
        self.license_plate = requestedCar
        
        self.sendMessage(requestedCar)
        
//        receiveMessage()
        await setReceiveHandler()
        print("Connected")
    }
    
//    private func receiveMessage() {
//        print("Listening... (\(self.counter))")
//        counter += 1
//        webSocketTask?.receive(completionHandler: { result in
//            switch result {
//                case .failure(let error):
//                    print("Received error: \(error.localizedDescription)")
//                    self.close()
//                    return
//                case .success(let message):
//                    switch message {
//                        case .string(let text):
//                            
//                            let jsonData = Data(text.utf8)
//                            
//                            let (safeResponse, safeError) = initWebsocketResponse(dataCuccli: jsonData)
//                            
//                            if let safeResponse {
//                                if safeResponse.status == "success" {
//                                    self.close()
//                                    if !self.dataSheetOpened {
//                                        self.openSheet()
//                                    }
//                                    return
//                                } else {
//                                    if let safeKey = safeResponse.key {
//                                        if let safeValue = safeResponse.value {
//                                            self.setValues(safeValue, key: safeKey)
//                                        }
//                                    }
//                                    self.percentage = safeResponse.percentage
//                                }
//                            }
//                            if let safeError {
//                                print("error: \(safeError)")
//                            }
//                        case .data(let data):
//                                // Handle binary data
//                            print(data)
//                            
//                            break
//                        @unknown default:
//                            break
//                    }
//            }
//            
//            if self.counter < 100 {
//                self.receiveMessage()
//            } else {
//                print("Forced close")
//                self.close()
//            }
//        })
//    }
    
    func setReceiveHandler() async {
        guard webSocketTask?.closeCode == .invalid else {
            return
        }
        
        do {
            let message = try await webSocketTask?.receive()
            
            switch message {
                case .string(let text):
                    
                    let jsonData = Data(text.utf8)
                    
                    let (safeResponse, safeError) = initWebsocketResponse(dataCuccli: jsonData)
                    
                    if let safeResponse {
                        if safeResponse.status == "success" {
                            self.close()
                            await self.getInspections(self.license_plate)
                            if !self.dataSheetOpened {
                                self.openSheet()
                            }
                            return
                        } else {
                            if let safeKey = safeResponse.key {
                                if let safeValue = safeResponse.value {
                                    self.setValues(safeValue, key: safeKey)
                                }
                            }
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
            
            if self.counter < 100 {
                print("===========================")
                await setReceiveHandler()
            } else {
                print("Forced close")
                self.close()
            }
        } catch {
            print(error)
        }
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
        self.counter = 0
        self.setLoading(false)
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
