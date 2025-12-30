//
//  SocketIO.swift
//  car-thingy_SwiftUI
//
//  Created by Martin Terhes on 2025. 12. 14..
//

import Foundation
import UIKit
import SocketIO

@Observable class Socketio {
    var manager: SocketManager!
    var socket: SocketIOClient!

    var car: Car = Car()

    var messages: [String] = []
    var percentage = Double()
    var isLoading = Bool()
    var isSuccess = false
    var areImagesLoaded = false
    var dataSheetOpened = false
    var error = String()
    var isAlert = false
    var isAlertSheetView = false    // show alert on sheetView only, so it doesn't dismiss the sheet
    var isQuerySaved = false
    
    var verificationDialogOpen = false
    
    enum HapticType: String {
        case notification
        case standard
        case error
    }
    
    enum AlertLocations: String {
        case notQuerySheetView
        case querySheetView
    }
    
    init() {
        setDev()
        manager = SocketManager(
            socketURL: URL(string: "http://10.11.12.5:8000")!, 
            config: [.log(true), .extraHeaders(["x-api-key": apiKey])]
        )
        socket = manager.defaultSocket
        socket.connect()
        setupSocketEvents()
    }
    
    // MARK: Socket events
    func setupSocketEvents() {
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        
        socket.on(clientEvent: .disconnect) {data, ack in
            print("socket disconnected")
        }
        
        socket.on("pong") { (data, ack) in
//            guard let response = data as? [String: Any] else {
//                return
//            }
            print("Event received: \(data)")
        }
        
        socket.on("car_response") { (data, ack) in
            // TODO: Handle empty data
            print(data[0])
            let jsonData = String(describing: data[0] as AnyObject)
            let (safeResponse, safeError) = initWebsocketResponse(dataCuccli: Data(jsonData.utf8))
            if let safeResponse {
                if safeResponse.status == "success" {
//                    await getInspections(car.licensePlate)
                    self.isSuccess = true
                    print(self.car)
                    self.haptic(type: .notification)
                } else if safeResponse.status == "waiting" {
                    self.openCodeDialog()
                } else {
                    if let safeKey = safeResponse.key {
                        if let safeValue = safeResponse.value {
                            self.setValues(
                                safeValue,
                                key: safeKey
                            )
                        }
                    }
                    self.percentage = safeResponse.percentage
                }
            }
            if let safeError {
                print("error: \(safeError)")
                if self.dataSheetOpened {
//                    showAlert(.querySheetView, safeError)
                } else {
//                    showAlert(.notQuerySheetView, safeError)
                }
            }
        }
    }
    
    // MARK: Send ping
    func sendPing() {
        socket.emit("ping")
    }
    
    // MARK: Send test request
    func sendTest() {
        socket.emit("request_license_plate", "test111")
    }
    
    // MARK: Send 2FA code
    func send2FACode(code: String) {
        socket.emit("input_2fa", code)
    }
    
    // MARK: Send car request
    func sendCarRequest(licensePlate: String) {
        self.reset()
        car.licensePlate = licensePlate
        socket.emit("request_license_plate", licensePlate)
    }
    
    // MARK: Cancel request
    func cancelRequest() {
        socket.emit("stop_request")
    }

    // MARK: Disconnect
    func disconnect() {
        socket.disconnect()
    }
    
    // MARK: Reset variables
    func reset() {
        car = Car()
        messages = []
    }
    
    // MARK: Set car values
    func setValues(_ value: WebsocketResponseType, key: CarDataType = .brand) {
        switch value {
            case .accidents(let accidents):
                car.accidents = accidents
            case .restrictions(let restrictions):
                car.restrictions = parseRestrictions(restrictions, car.licensePlate)
            case .mileage(let mileage):
                car.mileage = mileage
            case .stringValue(let stringValue):
                switch key {
                    case CarDataType.brand:
                        car.brand = stringValue
                        if !self.dataSheetOpened {
                            self.openSheet()
                        }
                        break
                    case CarDataType.color:
                        car.color = stringValue
                        break
                    case CarDataType.first_reg:
                        car.firstReg = stringValue
                        break
                    case CarDataType.first_reg_hun:
                        car.firstRegHun = stringValue
                        break
                    case CarDataType.fuel_type:
                        car.fuelType = stringValue
                        break
                    case CarDataType.gearbox:
                        car.gearbox = stringValue
                        break
                    case CarDataType.model:
                        car.model = stringValue
                        break
                    case CarDataType.status:
                        car.status = stringValue
                        break
                    case CarDataType.type_code:
                        car.typeCode = stringValue
                        break
                    case CarDataType.license_plate:
                        print("setValues - licenseplate")
                        break
                    default:
                        break
                }
            case .intValue(let intValue):
                switch key {
                    case CarDataType.engine_size:
                        car.engineSize = intValue
                        break
                    case CarDataType.num_of_owners:
                        car.numOfOwners = intValue
                        break
                    case CarDataType.performance:
                        car.performance = intValue
                        break
                    case CarDataType.year:
                        car.year = intValue
                        break
                    default:
                        break
                }
            case .message(let message):
                self.messages.append(message)
//                DDLogDebug("Message: \(message)")
                break
            default:
                print("default value: \(value)")
                break
        }
    }
    
    // MARK: Code dialog
    func openCodeDialog() {
        self.dataSheetOpened = true
        self.verificationDialogOpen = true
    }
    
    func dismissCodeDialog(verificationCode: String) {
        self.verificationDialogOpen = false
        self.send2FACode(code: verificationCode)
    }
    
    // MARK: Set/Clear values
    func setLoading(_ newStatus: Bool) {
        self.isLoading = newStatus
    }
    
    // MARK: Sheet
    func openSheet() {
        self.dataSheetOpened = true
    }
    
    func dismissSheet() {
        self.dataSheetOpened = false
    }
    
    // MARK: Get formatted license plate
    func getLP() -> String {
        var formattedLicensePlate = car.licensePlate.uppercased()
        
        if (formattedLicensePlate != "ERROR") {
            var numOfLetters = 0
            
            for char in formattedLicensePlate {
                if (char.isLetter) {
                    numOfLetters += 1
                }
            }
            
            formattedLicensePlate.insert(contentsOf: "-", at: formattedLicensePlate.index(formattedLicensePlate.startIndex, offsetBy: numOfLetters))
            
                // if it's the new license plate
            if (car.licensePlate.count > 6) {
                formattedLicensePlate.insert(contentsOf: " ", at: formattedLicensePlate.index(formattedLicensePlate.startIndex, offsetBy: 2))
            }
        }
        
        return formattedLicensePlate
    }
    
    // MARK: Inspections
    func getInspections(_ licensePlate: String) async {
        let (inspections, error) = await loadQueryInspections(license_plate: licensePlate)
        if let safeInspections = inspections {
            car.inspections = safeInspections
            self.areImagesLoaded = true
        }
        if let safeError = error {
            self.showAlert(.querySheetView, safeError)
            self.areImagesLoaded = true
        }
    }
    
    // MARK: Restricrions
    func parseRestrictions(_ stringRestrictions: [String], _ licensePlate: String) -> [Restriction] {
        var newRestrictions: [Restriction] = []
        for restriction in stringRestrictions {
            newRestrictions.append(Restriction(
                licensePlate: licensePlate,
                restriction: restriction,
//                restrictionDate: Date.now.ISO8601Format(),
                isActive: true
            ))
        }
        return newRestrictions
    }
    
    // MARK: Alert
    func showAlert(_ alertLocation: AlertLocations,_ error: String) {
        self.error = error
        switch alertLocation {
            case .notQuerySheetView:
                self.isAlert = true
            case .querySheetView:
                self.isAlertSheetView = true
        }
        self.isLoading = false
        self.haptic(type: .error)
    }
    
    func disableAlert() {
        self.error = String()
        self.isAlert = false
        self.isAlertSheetView = false
    }
    
    func close() {
        self.percentage = 0.0
        self.setLoading(false)
    }
    
    // MARK: Haptic
    func haptic(type: HapticType = .standard, intensity: CGFloat = 0.5) {
        print("Haptic")
        switch type {
            case .standard:
                let impact = UIImpactFeedbackGenerator()
                impact.prepare()
                impact.impactOccurred(intensity: intensity)
            case .notification:
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(.success)
            case .error:
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(.error)
        }
    }
}
