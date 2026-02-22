//
//  HTTP.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/30/22.
//

import Foundation
import CocoaLumberjackSwift

var carsLoaded: Bool = false
var coordinatesLoaded: Bool = false
var statisticsLoaded: Bool = false

func setCarsLoaded(_ newStatus: Bool) {
	print("carsLoaded: \(newStatus)")
	carsLoaded = newStatus
}

func setStatisticsLoaded(_ newStatus: Bool) {
	print("statisticsLoaded: \(newStatus)")
	statisticsLoaded = newStatus
}



// MARK: New Car query
/// Process query response
/// - Parameters:
///     - dataCuccli: Data received from server
/// - Returns: Tuple with QueryResponse object or error message
func initQueryResponse(dataCuccli: Data) -> (response: QueryResponse?, error: String?) {
    var decodedData: QueryResponse
    
    do {
        decodedData = try JSONDecoder().decode(QueryResponse.self, from: dataCuccli)
        
        if (decodedData.status == "success") {
            print("status (query): \(decodedData)")
            return (decodedData, nil)
        } else if (decodedData.status == "pending") {
            print("status (query): \(decodedData)")
            return (decodedData, nil)
		} else if (decodedData.status == "fail") {
			print("status (query): \(decodedData)")
			return (nil, decodedData.errorMessage)
		} else if (decodedData.status == "waiting") {
			print("status (query): \(decodedData)")
			return (decodedData, nil)
        } else {
            DDLogError("Failed response: No error message from server")
            return (nil, "No error message from server")
        }
        
    } catch {
		DDLogError("initQueryResponse error: \(error)")
        return (nil, error.localizedDescription)
    }
}

/// Load query inspections
/// - Parameters:
///     - license_plate: License plate of the car to query
/// - Returns: Tuple with array of Inspection objects or error message
func loadQueryInspections(license_plate: String) async -> (inspections: [Inspection]?, error: String?) {
	let url = URL(string: getURLasString(.queryInspections) + "/" + license_plate.uppercased())!
	
	do {
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
		let (data, _) = try await URLSession.shared.data(for: request)
		
		return initInspections(dataCuccli: data)
	} catch {
		DDLogError("Invalid inspection data")
		return (nil, error.localizedDescription)
	}
}


// MARK: Inspections
/// Load inspections
/// - Parameters:
///     - license_plate: License plate of the car to load inspections for
/// - Returns: Tuple with array of Inspection objects or error message
func loadInspections(license_plate: String) async -> (inspections: [Inspection]?, error: String?) {
    let url = URL(string: getURLasString(.inspections) + "/" + license_plate.uppercased())!
    
    do {
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
		let (data, _) = try await URLSession.shared.data(for: request)
        
        return initInspections(dataCuccli: data)
    } catch {
		DDLogError("Invalid inspection data")
        return (nil, error.localizedDescription)
    }
}

/// Process inspections response
/// - Parameters:
///     - dataCuccli: Data received from server
/// - Returns: Tuple with array of Inspection objects or error message
func initInspections(dataCuccli: Data) -> (inspections: [Inspection]?, error: String?) {
    var decodedInspections: InspectionResponse
    
    do {
        decodedInspections = try JSONDecoder().decode(InspectionResponse.self, from: dataCuccli)
        
        if (decodedInspections.isSuccess()) {
            print("status (Inspections): \(decodedInspections.isSuccess())")
			return (decodedInspections.data, nil)
        } else {
            return (nil, "No error message from server (?)")
        }
        
    } catch {
		DDLogError(String(data: dataCuccli, encoding: .utf8) ?? "???")
		DDLogError("initInspections error: \(error)")
        return (nil, error.localizedDescription)
    }
}



// MARK: MyCars
/// Load cars
/// - Parameters:
///     - refresh: Bool indicating whether to force refresh from server
/// - Returns: Tuple with array of Car objects or error message
func loadCars(_ refresh: Bool = false) async -> (cars: [Car]?, error: String?) {
    if !carsLoaded || refresh {
        let url = getURL(.cars)
        
        do {
			var request = URLRequest(url: url)
			request.httpMethod = "GET"
			request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
			
			let (data, metadata) = try await URLSession.shared.data(for: request)

            return initData(dataCuccli: data)
        } catch {
			DDLogError("Invalid data in loadCars: \(error)")
            return (nil, error.localizedDescription)
        }
    }
    print("Cars are already loaded")
    return (nil,nil)
}

/// Load single car
/// - Parameters:
///     - license_plate: License plate of the car to load
/// - Returns: Tuple with array of Car objects or error message
func loadCar(license_plate: String) async -> (cars: [Car]?, error: String?) {
    let url = URL(string: getURLasString(.cars) + "/" + license_plate.uppercased())!
    
    do {
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
		let (data, metadata) = try await URLSession.shared.data(for: request)
        
        return initData(dataCuccli: data, onlyOne: true)
    } catch {
		DDLogError("Invalid data in loadCar: \(error)")
        return (nil, error.localizedDescription)
    }
}

/// Process car(s) response
/// - Parameters:
///     - dataCuccli: Data received from server
///     - onlyOne: Bool indicating whether only one car is expected
/// - Returns: Tuple with array of Car objects or error message
func initData(dataCuccli: Data, onlyOne: Bool = false) -> (cars: [Car]?, error: String?) {
    var decodedData: CarResponse
    
    do {
        decodedData = try JSONDecoder().decode(CarResponse.self, from: dataCuccli)
        
        switch decodedData.status {
            case "success":
				print(onlyOne ? "status (Car): \(decodedData.status)" : "status (Cars): \(decodedData.status)")
				
				for i in 0 ..< decodedData.data!.count {
					let _ = decodedData.data![i].getDate(.createdAt)
					let _ = decodedData.data![i].getDate(.updatedAt)
				}
				
				if !onlyOne {
					setCarsLoaded(true)
				}
				
                return (decodedData.data, nil)
            case "fail":
				DDLogError("Failed response: \(decodedData.message ?? "No response??")")
                return (nil, "Server error: \(decodedData.message ?? "No response??")")
            default:
                return (nil, "Status is not success or fail?")
        }
    } catch {
		DDLogError("initData error: \(error)")
        return (nil, error.localizedDescription)
    }
}

// MARK: Save Car
/// Save car data
/// - Parameters:
///     - uploadableCarData: Car object to upload
///     - isPost: Bool indicating whether to use POST (true) or PUT (false), create vs update
/// - Returns: Tuple with response string or error message
func saveData(uploadableCarData: Car, isPost: Bool) async -> (response: String?, error: String?) {
    uploadableCarData.toString()
    
    guard let encoded = try? JSONEncoder().encode(uploadableCarData) else {
		DDLogError("Failed to encode car")
        return (nil, "Failed to encode car")
    }
    
    var request = URLRequest(url: getURL(.cars))
    
    request.httpMethod = isPost ? "POST" : "PUT"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
	request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        
    do {
        let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            //        print(String(decoding: request.httpBody ?? Data(), as: UTF8.self))
//        print(String(data: data, encoding: .utf8) ?? "???")
                
        return initSaveResponse(dataCuccli: data)
    } catch {
		DDLogError("saveData failed: \(error.localizedDescription)")
        return (nil, "saveData failed: \(error.localizedDescription)")
    }
}

/// Update license plate of a car
/// - Parameters:
///     - newCarObject: Car object with new license plate
///     - oldLicensePlate: Old license plate string
/// - Returns: Tuple with response string or error message
func updateLicensePlate(newCarObject: Car, oldLicensePlate: String) async -> (response: String?, error: String?) {
	guard let encoded = try? JSONEncoder().encode(newCarObject) else {
		DDLogError("Failed to encode license plate object")
		return (nil, "Failed to encode license plate object")
	}
	
	let url = URL(string: getURLasString(.licensePlate) + "/" + oldLicensePlate.uppercased())!
	var request = URLRequest(url: url)
	
	request.httpMethod = "PUT"
	request.setValue("application/json", forHTTPHeaderField: "Content-Type")
	request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
	
	do {
		let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
//		print(String(data: data, encoding: .utf8) ?? "???")
		
		return initSaveResponse(dataCuccli: data)
	} catch {
		DDLogError("Checkout failed.")
		return (nil, "Checkout failed")
	}
}

/// Process save response
/// - Parameters:
///     - dataCuccli: Data received from server
/// - Returns: Tuple with response string or error message
func initSaveResponse(dataCuccli: Data) -> (response: String?, error: String?) {
    var decodedData: GoResponse
    
    do {
        decodedData = try JSONDecoder().decode(GoResponse.self, from: dataCuccli)
        print(decodedData)
        
        switch decodedData.status {
            case "success":
                print("status (saveCar) success: \(decodedData.status)")
                coordinatesLoaded = false
				setCarsLoaded(false)
				return (decodedData.data, nil)
            case "fail":
                print("status (saveCar) failed: \(decodedData.message)")
                return (nil, "Server error: \(decodedData.message)")
            default:
                return (nil, "Status is not success or fail?")
        }
    } catch {
		DDLogError(String(data: dataCuccli, encoding: .utf8) ?? "???")
		DDLogError("initSaveResponse error: \(error)")
        return (nil, error.localizedDescription)
    }
}

/// Used for deleting car from list
/// - Parameters:
///     - request: URLRequest object for DELETE request
///     - cars: Array of Car objects
///     - offsets: IndexSet of offsets to delete
///     - completionHandler: Completion handler with updated array of Car objects or error message
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
			DDLogError("Error: error calling DELETE")
			DDLogError("deleteData error: \(String(describing: error))")
            errorMsg = "Error calling DELETE \n \(String(describing: error))"
            completionHandler(cars, errorMsg)
            return
        }
        guard let data = data else {
			DDLogError("Error: Did not receive data")
            errorMsg = "Did not receive data in deleteData"
            completionHandler(cars, errorMsg)
            return
        }
        
        do {
            var decodedData: DeleteResponse
            decodedData = try JSONDecoder().decode(DeleteResponse.self, from: data)
            print(decodedData.data as Any)
            coordinatesLoaded = false
        } catch {
			DDLogError("Error: Trying to convert JSON data to string")
			DDLogError("Error during decoding in deleteData. Error: \(error)")
            errorMsg = "Error during decoding in deleteData \n \(error)"
                //            cars = cars
            completionHandler(cars, errorMsg)
            return
        }
        
        cars.remove(atOffsets: offsets)
        
        completionHandler(cars, errorMsg)
    }.resume()
}


// MARK: Map
// Used for deleting cars generally
func deleteCarHelper (
    request: inout URLRequest,
    completionHandler: @escaping (_ successMsg: String?, _ errorMsg: String?) -> Void
) {
    
    var successMsg: String?
    var errorMsg: String?
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil else {
			DDLogError("Error: error calling DELETE")
			DDLogError("deleteCarHelper error: \(String(describing: error))")
            errorMsg = "Error calling DELETE \n \(String(describing: error))"
            completionHandler(nil, errorMsg)
            return
        }
        guard let data = data else {
			DDLogError("Error: Did not receive data")
            errorMsg = "Did not receive data in deleteCarHelper"
            completionHandler(nil, errorMsg)
            return
        }
        
        do {
            var decodedData: DeleteResponse
			print(String(data: data, encoding: .utf8) ?? "???")
            decodedData = try JSONDecoder().decode(DeleteResponse.self, from: data)
            print(decodedData.data as Any)
            coordinatesLoaded = false
			setCarsLoaded(false)
            successMsg = decodedData.data
        } catch {
			DDLogError("Error: Trying to convert JSON data to string")
			DDLogError("Error during decoding in deleteCarHelper. Error: \(error)")
            errorMsg = "Error during decoding in deleteCarHelper \n \(error)"
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
	request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
    
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


// MARK: Statistics page
/// Load statistics
/// - Parameters:
///     - refresh: Bool indicating whether to force refresh from server
/// - Returns: Tuple with Statistics object or error message
func loadStatistics(_ refresh: Bool = false) async -> (success: Statistics?, error: String?) {
	if !statisticsLoaded || refresh {
		let url = getURL(.statistics)
		
		do {
			var request = URLRequest(url: url)
			request.httpMethod = "GET"
			request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
			
			let (data, metadata) = try await URLSession.shared.data(for: request)
			
			return initStats(dataCuccli: data)
		} catch {
			DDLogError("Invalid data in loadStatistics: \(error)")
			return (nil, error.localizedDescription)
		}
	}
	print("Statistics are already loaded")
	return (nil,nil)
}

/// Process statistics response
/// - Parameters:
///     - dataCuccli: Data received from server
/// - Returns: Tuple with Statistics object or error message
func initStats(dataCuccli: Data) -> (success: Statistics?, error: String?) {
	var decodedResponse: StatisticsResponse
	
	do {
		decodedResponse = try JSONDecoder().decode(StatisticsResponse.self, from: dataCuccli)
		
		switch decodedResponse.status {
			case "success":
				setStatisticsLoaded(true)
				return (decodedResponse.data, nil)
			case "fail":
				DDLogError(String(data: dataCuccli, encoding: .utf8) ?? "???")
				DDLogError("Failed response (initStats): \(decodedResponse.message ?? "No response??")")
				return (nil, "Server error: \(decodedResponse.message ?? "No response??")")
			default:
				return (nil, "Status is not success or fail?")
		}
	} catch {
		DDLogError("initStats error: \(error)")
		DDLogError(String(data: dataCuccli, encoding: .utf8) ?? "???")
		return (nil, error.localizedDescription)
	}
}
