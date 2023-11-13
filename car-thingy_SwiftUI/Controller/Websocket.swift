//
//  Websocket.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 10/30/23.
//

import Foundation

@Observable class Websocket {
    var messages = [String]()
    var percentage = Double()
    var isLoading = Bool()
    var isSuccess = false
    var dataSheetOpened = false
    var error = String()
    var showAlert = false
    
    var license_plate = String()
    
    var brand = String()
    var color = String()
    var engine_size = Int()
    var first_reg = String()
    var first_reg_hun = String()
    var fuel_type = String()
    var gearbox = String()
    var model = String()
    var num_of_owners = Int()
    var performance = Int()
    var status = String()
    var type_code = String()
    var year = Int()
    
    var accidents = [Accident()]
    var restrictions = [String()]
    var mileage = [Mileage()]
    var inspections = [Inspection()]
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var counter = 0
    
    init(preview: Bool = false) {
        if preview {
            license_plate = testCar.license_plate
            brand = testCar.brand
            color = testCar.color
            engine_size = testCar.engine_size
            first_reg = testCar.first_reg
            first_reg_hun = testCar.first_reg_hun
            fuel_type = testCar.fuel_type
            gearbox = testCar.gearbox
            model = testCar.model
            num_of_owners = testCar.num_of_owners
            performance = testCar.performance
            status = testCar.status
            year = testCar.year
            
            accidents = testCar.accidents!
            restrictions = testCar.restrictions!
            mileage = testCar.mileage!
            inspections = testCar.inspections!
            
            isLoading = true
            messages = [
                "Message 1",
                "Message 2",
                "Message 3",
                "Message 4",
                "Message 5",
                "Message 6",
                "Message 7",
                "Message 8"
            ]
        }
    }
    
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
                        if !self.dataSheetOpened {
                            self.openSheet()
                        }
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
                    case CarDataType.license_plate:
                        self.license_plate = license_plate
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
        self.isLoading = false
        self.close()
    }
    
    func disableAlert() {
        self.error = String()
        self.showAlert = false
    }
    
    func connect(_ requestedCar: String) async {
        self.setLoading(true)
        guard let url = URL(string: getURLasString(.query)) else { return }
        let request = URLRequest(url: url)
        
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        print("Connected")
        
        MyCarsView().haptic(type: .standard)
        
        self.counter = 0
        self.clearValues()
        
        self.license_plate = requestedCar
        self.sendMessage(requestedCar)
        
            //        receiveMessage()
        await setReceiveHandler()
    }
        
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
                            self.isSuccess = true
                            MyCarsView().haptic(type: .notification)
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
                        self.enableAlert(error: safeError)
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
