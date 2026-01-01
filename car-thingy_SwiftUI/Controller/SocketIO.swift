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
    
    // MARK: Init
    init() {
        setDev()
        manager = SocketManager(
            socketURL: URL(string: getURLasString(.query))!,
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
            self.reset()
        }
        
        socket.on("pong") { (data, ack) in
//            guard let response = data as? [String: Any] else {
//                return
//            }
            print("Event received: \(data)")
        }
        
        socket.on("car_response") { (data, ack) in
            if data.isEmpty {
                if self.dataSheetOpened {
                    self.showAlert(.querySheetView, "car_response data was empty")
                } else {
                    self.showAlert(.notQuerySheetView, "car_response data was empty")
                }
                return
            }
            let jsonData = String(describing: data[0] as AnyObject)
            let (safeResponse, safeError) = initQueryResponse(dataCuccli: Data(jsonData.utf8))
            if let safeResponse {
                if safeResponse.status == "success" {
                    // Task is required here because socket.on is synchronous, so to get the inspections asyncly, it needs to be in a Task to get Swift handle it asyncly
                    Task {
                        await self.getInspections(self.car.licensePlate)
                        await MainActor.run {
                            self.isSuccess = true
                            self.isLoading = false
                            self.haptic(type: .notification)
                       }
                   }
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
                    if safeResponse.percentage != -1 {
                        self.percentage = safeResponse.percentage
                    }
                }
            }
            if let safeError {
                print("error: \(safeError)")
                if self.dataSheetOpened {
                    self.showAlert(.querySheetView, safeError)
                } else {
                    self.showAlert(.notQuerySheetView, safeError)
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
        self.car.licensePlate = "TEST111"
        self.isLoading = true
    }
    
    // MARK: Send 2FA code
    func send2FACode(_ code: String) {
        socket.emit("input_2fa", code)
    }
    
    // MARK: Send car request
    func sendCarRequest(_ licensePlate: String) {
        self.reset()
        self.isLoading = true
        car.licensePlate = licensePlate
        socket.emit("request_license_plate", licensePlate)
    }
    
    // MARK: Cancel request
    func sendCarRequestCancel() {
        socket.emit("stop_request")
        self.isLoading = false
    }

    // MARK: Disconnect
    func disconnect() {
        socket.disconnect()
        self.isLoading = false
    }
    
    // MARK: Reset variables
    func reset() {
        car = Car()
        messages = []
        self.isSuccess = false
        self.areImagesLoaded = false
        self.isLoading = false
        print("Query car RESET")
    }

    
    /// Set car values as received from server
    /// - Parameters:
    ///   - value: Value to set
    ///   - key: Key to set
    func setValues(_ value: CarQueryResponseType, key: CarDataType = .brand) {
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
        self.send2FACode(verificationCode)
    }
    
    // MARK: Set loading
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
    
    /// Formats the license plate
    /// - Returns: Formatted license plate like "AA AA-111 or AAA-111"
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
    
    /// Downloads the inspections including images from the server
    /// - Parameter licensePlate: License plate to query the inspections of
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
    
    /// Parses the string restrictions into a list of restrictions
    /// - Parameters:
    ///   - stringRestrictions: List of string restrictions
    ///   - licensePlate: License plate of the car
    func parseRestrictions(_ stringRestrictions: [String], _ licensePlate: String) -> [Restriction] {
        var newRestrictions: [Restriction] = []
        for restriction in stringRestrictions {
            newRestrictions.append(Restriction(
                licensePlate: licensePlate,
                restriction: restriction,
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
    
    // MARK: Cancel
    func cancelCarRequest() {
        self.sendCarRequestCancel()
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
