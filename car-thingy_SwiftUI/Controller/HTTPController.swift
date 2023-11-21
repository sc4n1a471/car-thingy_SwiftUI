//
//  HTTP.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/30/22.
//

import Foundation

var carsLoaded: Bool = false
var coordinatesLoaded: Bool = false


// MARK: New Car query
func initWebsocketResponse(dataCuccli: Data) -> (response: WebsocketResponse?, error: String?) {
    var decodedData: WebsocketResponse
    
    do {
        decodedData = try JSONDecoder().decode(WebsocketResponse.self, from: dataCuccli)
        
        if (decodedData.status == "success") {
            print("status (query): \(decodedData)")
            return (decodedData, nil)
        } else if (decodedData.status == "pending") {
            print("status (query): \(decodedData)")
            return (decodedData, nil)
        } else if (decodedData.status == "fail") {
            print("status (query): \(decodedData)")
            return (nil, decodedData.errorMessage)
        } else {
            print("Failed response: No error message from server")
            return (nil, "No error message from server")
        }
        
    } catch {
        print("initWebhookResponse error: \(error)")
        return (nil, error.localizedDescription)
    }
}

// MARK: Inspections
func loadInspections(license_plate: String) async -> (inspections: [Inspection]?, error: String?) {
    let url = URL(string: getURLasString(.inspections) + "/" + license_plate.uppercased())!
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        
        return initInspections(dataCuccli: data)
    } catch {
        print("Invalid inspection data")
        return (nil, error.localizedDescription)
    }
}

func initInspections(dataCuccli: Data) -> (inspections: [Inspection]?, error: String?) {
    var decodedInspections: InspectionResponse
    
    do {
        decodedInspections = try JSONDecoder().decode(InspectionResponse.self, from: dataCuccli)
        
        if (decodedInspections.isSuccess()) {
            print("status (Inspections): \(decodedInspections.isSuccess())")
            return (decodedInspections.message, nil)
        } else {
            return (nil, "No error message from server (?)")
        }
        
    } catch {
        print("initInspections error: \(error)")
        return (nil, error.localizedDescription)
    }
}

func deleteInspectionHelper (
	request: inout URLRequest,
	completionHandler: @escaping (_ successMsg: String?, _ errorMsg: String?) -> Void
) {
	
	var successMsg: String?
	var errorMsg: String?
	
	URLSession.shared.dataTask(with: request) { data, response, error in
		guard error == nil else {
			print("Error: error calling DELETE")
			print("deleteData error: \(String(describing: error))")
			errorMsg = "Error calling DELETE \n \(String(describing: error))"
			completionHandler(nil, errorMsg)
			return
		}
		guard let data = data else {
			print("Error: Did not receive data")
			errorMsg = "Did not receive data in deleteData"
			completionHandler(nil, errorMsg)
			return
		}
		
		do {
			var decodedData: DeleteResponse
			decodedData = try JSONDecoder().decode(DeleteResponse.self, from: data)
			print(decodedData.message as Any)
			coordinatesLoaded = false
			carsLoaded = false
			successMsg = decodedData.message
		} catch {
			print("Error: Trying to convert JSON data to string")
			print("Error during decoding in deleteData. Error: \(error)")
			errorMsg = "Error during decoding in deleteData \n \(error)"
			completionHandler(nil, errorMsg)
			return
		}
		
		completionHandler(successMsg, errorMsg)
	}.resume()
}

func deleteInspection(licensePlate: String) async throws -> (success: String?, error: String?) {
	let url1 = getURLasString(.inspections) + "/" + licensePlate.uppercased()
	let urlFormatted = URL(string: url1)
	var request = URLRequest(url: urlFormatted!)
	request.httpMethod = "DELETE"
	
	return try await withCheckedThrowingContinuation ({ (continuation: CheckedContinuation) in
		deleteInspectionHelper(request: &request) { (deleteSuccess, deleteError) in
			if let deleteSuccess {
				continuation.resume(returning: (deleteSuccess, deleteError))
			}
			
			if let deleteError {
				continuation.resume(returning: (deleteSuccess, deleteError))
			}
		}
	})
}

// MARK: MyCars
func loadCars(_ refresh: Bool = false) async -> (cars: [Car]?, error: String?) {
    if !carsLoaded || refresh {
        let url = getURL(.cars)
        
        do {
                // (data, metadata)-ban metadata most nem kell, ezért lehet _
            let (data, _) = try await URLSession.shared.data(from: url)
            
                //        if (String(data: data, encoding: .utf8)?.contains("502") == true) {
                //            returnedData.error = "Could not reach API (502)"
                //            returnedData.cars = [errorCar]
                //            return returnedData
                //        }
            return initData(dataCuccli: data)
        } catch {
            print("Invalid data in loadCars: \(error)")
            return (nil, error.localizedDescription)
        }
    }
    print("Cars are already loaded")
    return (nil,nil)
}

func loadCar(license_plate: String) async -> (cars: [Car]?, error: String?) {
    let url = URL(string: getURLasString(.cars) + "/" + license_plate.uppercased())!
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        
//        if (String(data: data, encoding: .utf8)?.contains("502") == true) {
//            return (nil, "Could not reach API (502)")
//        }
        
        return initData(dataCuccli: data, carOnly: true)
    } catch {
        print("Invalid data in loadCar: \(error)")
        return (nil, error.localizedDescription)
    }
}

func initData(dataCuccli: Data, carOnly: Bool = false) -> (cars: [Car]?, error: String?) {
    var decodedData: CarResponse
    
    do {
        decodedData = try JSONDecoder().decode(CarResponse.self, from: dataCuccli)
        
        switch decodedData.status {
            case "success":
                print("status (Cars): \(decodedData.status)")
                if !carOnly {
                    carsLoaded = true
                }
                return (decodedData.message, nil)
            case "failed":
                print("Failed response: \(decodedData.message)")
                return (nil, "Server error")
            default:
                return (nil, "Status is not success or failed?")
        }
    } catch {
        print("initData error: \(error)")
        return (nil, error.localizedDescription)
    }
}

func saveData(uploadableCarData: Car, isPost: Bool, lpOnly: Bool = true) async -> (response: String?, error: String?) {
    uploadableCarData.toString()
    
    guard let encoded = try? JSONEncoder().encode(uploadableCarData) else {
        print("Failed to encode car")
        return (nil, "Failed to encode car")
    }
    
    var url: URL
    url = lpOnly ? getURL(.licensePlate) : getURL(.cars)
    var request = URLRequest(url: url)
    
    request.httpMethod = isPost ? "POST" : "PUT"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
    do {
        let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            //        print(String(decoding: request.httpBody ?? Data(), as: UTF8.self))
//        print(String(data: data, encoding: .utf8) ?? "???")
                
        carsLoaded = false
        return initSaveResponse(dataCuccli: data)
    } catch {
        print("Checkout failed.")
        return (nil, "Checkout failed")
    }
}

func initSaveResponse(dataCuccli: Data) -> (response: String?, error: String?) {
    var decodedData: GoResponse
    
    do {
        decodedData = try JSONDecoder().decode(GoResponse.self, from: dataCuccli)
        print(decodedData)
        
        switch decodedData.status {
            case "success":
                print("status (saveCar) success: \(decodedData.status)")
                coordinatesLoaded = false
                carsLoaded = false
                return (decodedData.message, nil)
            case "failed":
                print("status (saveCar) failed: \(decodedData.message)")
                return (nil, "Server error: \(decodedData.message)")
            default:
                return (nil, "Status is not success or failed?")
        }
    } catch {
        print("initData error: \(error)")
        return (nil, error.localizedDescription)
    }
}

// Used for deleting car from list
func deleteHelper (
    request: inout URLRequest,
    cars: [Car],
    offsets: IndexSet,
    completionHandler: @escaping (_ cars: [Car]?, _ errorMsg: String?) -> Void
) {
    
    let request = request
    var cars = cars
    var errorMsg: String?
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil else {
            print("Error: error calling DELETE")
            print("deleteData error: \(String(describing: error))")
            errorMsg = "Error calling DELETE \n \(String(describing: error))"
            completionHandler(cars, errorMsg)
            return
        }
        guard let data = data else {
            print("Error: Did not receive data")
            errorMsg = "Did not receive data in deleteData"
            completionHandler(cars, errorMsg)
            return
        }
        
        do {
            var decodedData: DeleteResponse
            decodedData = try JSONDecoder().decode(DeleteResponse.self, from: data)
            print(decodedData.message as Any)
            coordinatesLoaded = false
        } catch {
            print("Error: Trying to convert JSON data to string")
            print("Error during decoding in deleteData. Error: \(error)")
            errorMsg = "Error during decoding in deleteData \n \(error)"
                //            cars = cars
            completionHandler(cars, errorMsg)
            return
        }
        
        cars.remove(atOffsets: offsets)
        
        completionHandler(cars, errorMsg)
    }.resume()
}

func deleteData(at offsets: IndexSet, cars: [Car]) async throws -> (cars: [Car]?, error: String?) {
    
    let cars: [Car]? = cars
    
    let url1 = getURLasString(.cars) + "/" + (cars![offsets.first!].license_plate.license_plate).uppercased()
    let urlFormatted = URL(string: url1)
    var request = URLRequest(url: urlFormatted!)
    request.httpMethod = "DELETE"
    
    return try await withCheckedThrowingContinuation ({ (continuation: CheckedContinuation) in
        deleteHelper(request: &request, cars: cars!, offsets: offsets) { (deleteCars, deleteError) in
            if let deleteCars {
                continuation.resume(returning: (deleteCars, deleteError))
            }
            if let deleteError {
                continuation.resume(returning: (deleteCars, deleteError))
            }
        }
    })
}

// MARK: Map
func loadCoordinates() async -> (coordinates: [Coordinates]?, error: String?) {
    if !coordinatesLoaded {
        let url = getURL(.coordinates)
        
        do {
                // (data, metadata)-ban metadata most nem kell, ezért lehet _
            let (data, _) = try await URLSession.shared.data(from: url)

            return initCoordinates(dataCuccli: data)
        } catch {
            print("Invalid data in loadCoordinates: \(error)")
            return (nil, error.localizedDescription)
        }
    }
    print("Cars are already loaded")
    return (nil,nil)
}

func initCoordinates(dataCuccli: Data) -> (coordinates: [Coordinates]?, error: String?) {
    var decodedData: CoordinateResponse
    
    do {
        decodedData = try JSONDecoder().decode(CoordinateResponse.self, from: dataCuccli)
        
        switch decodedData.status {
            case "success":
                print("status (Coordinates): \(decodedData.status)")
                coordinatesLoaded = true
                return (decodedData.message, nil)
            case "failed":
                print("Failed response: \(decodedData.message)")
                return (nil, "Server error")
            default:
                return (nil, "Status is not success or failed?")
        }
    } catch {
        print("initData error: \(error)")
        return (nil, error.localizedDescription)
    }
}

// Used for deleting cars generally
func deleteCarHelper (
    request: inout URLRequest,
    completionHandler: @escaping (_ successMsg: String?, _ errorMsg: String?) -> Void
) {
    
    var successMsg: String?
    var errorMsg: String?
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil else {
            print("Error: error calling DELETE")
            print("deleteData error: \(String(describing: error))")
            errorMsg = "Error calling DELETE \n \(String(describing: error))"
            completionHandler(nil, errorMsg)
            return
        }
        guard let data = data else {
            print("Error: Did not receive data")
            errorMsg = "Did not receive data in deleteData"
            completionHandler(nil, errorMsg)
            return
        }
        
        do {
            var decodedData: DeleteResponse
            decodedData = try JSONDecoder().decode(DeleteResponse.self, from: data)
            print(decodedData.message as Any)
            coordinatesLoaded = false
            carsLoaded = false
            successMsg = decodedData.message
        } catch {
            print("Error: Trying to convert JSON data to string")
            print("Error during decoding in deleteData. Error: \(error)")
            errorMsg = "Error during decoding in deleteData \n \(error)"
            completionHandler(nil, errorMsg)
            return
        }
                
        completionHandler(successMsg, errorMsg)
    }.resume()
}

func deleteCar(licensePlate: String) async throws -> (success: String?, error: String?) {
    let url1 = getURLasString(.cars) + "/" + licensePlate.uppercased()
    let urlFormatted = URL(string: url1)
    var request = URLRequest(url: urlFormatted!)
    request.httpMethod = "DELETE"
    
    return try await withCheckedThrowingContinuation ({ (continuation: CheckedContinuation) in
        deleteCarHelper(request: &request) { (deleteSuccess, deleteError) in
            if let deleteSuccess {
                continuation.resume(returning: (deleteSuccess, deleteError))
            }
            
            if let deleteError {
                continuation.resume(returning: (deleteSuccess, deleteError))
            }
        }
    })
}
