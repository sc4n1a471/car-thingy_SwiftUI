//
//  HTTP.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/30/22.
//

import Foundation

let errorCar = Car(license_plate: "ERROR", brand_id: 1, brand: "ERROR", model: "ERROR", codename: "ERROR", year: 9999, comment: "ERROR", is_new: 1, latitude: 37.332914, longitude: -122.005202)
let errorBrand = Brand(brand_id: 1, brand: "ERROR")

var carsLoaded: Bool = false
var brandsLoaded: Bool = false

struct ReturnCarQuery {
    var queriedCar: CarQuery?
    var error: String = "DEFAULT_VALUE"
}

// MARK: Car
func loadData(_ refresh: Bool = false) async -> (cars: [Car]?, error: String?) {
    if !carsLoaded || refresh {
        let url = getURL(whichUrl: "cars")
        
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
            print("Invalid data")
            return ([errorCar], error.localizedDescription)
        }
    }
    print("Cars are already loaded")
    return (nil,nil)
}

func loadCar(license_plate: String) async -> (cars: [Car]?, error: String?) {
    let url = URL(string: getURLasString(whichUrl: "cars") + "/" + license_plate.uppercased())!
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        
        if (String(data: data, encoding: .utf8)?.contains("502") == true) {
            return ([errorCar], "Could not reach API (502)")
        }
        
        return initData(dataCuccli: data, carOnly: true)
    } catch {
        print("Invalid data")
        return ([errorCar], error.localizedDescription)
    }
}

func initData(dataCuccli: Data, carOnly: Bool = false) -> (cars: [Car]?, error: String?) {
    var decodedData: Response
    
    do {
        decodedData = try JSONDecoder().decode(Response.self, from: dataCuccli)
            
        if (decodedData.success) {
            print("status (Cars): \(decodedData.success)")
            if !carOnly {
                carsLoaded = true
            }
            return (decodedData.cars!, nil)
        } else {
            print("Failed response: \(decodedData.message ?? "No error message from server (?)")")
            return (cars: nil, error: decodedData.message ?? "No error message from server (?)")
        }

    } catch {
        print("initData error: \(error)")
        return ([errorCar], error.localizedDescription)
    }
}

func saveData(uploadableCarData: CarData, isUpload: Bool, isNewBrand: Bool = false) async -> Bool {
    print(uploadableCarData.car)
    guard let encoded = try? JSONEncoder().encode(uploadableCarData.car) else {
        print("Failed to encode order")
        return false
    }
    
    var url: URL
    url = isUpload ? getURL(whichUrl: "cars") : URL(string: getURLasString(whichUrl: "cars") + "/" + uploadableCarData.oldLicensePlate.uppercased())!
    var request = URLRequest(url: url)
            
    request.httpMethod = isUpload ? "POST" : "PUT"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    do {
        let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
//        print(String(decoding: request.httpBody ?? Data(), as: UTF8.self))
//        print(String(data: data, encoding: .utf8))
        carsLoaded = false
        if isNewBrand {
            brandsLoaded = false
        }
        return true
    } catch {
        print("Checkout failed.")
        return false
    }
}

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
            var decodedData: Response
            decodedData = try JSONDecoder().decode(Response.self, from: data)
            print(decodedData.message as Any)
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
    
    let url1 = getURLasString(whichUrl: "cars") + "/" + (cars![offsets.first!].license_plate).uppercased()
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


// MARK: Car query
func queryCar(license_plate: String) async -> ReturnCarQuery {
    let url = URL(string: getURLasString(whichUrl: "carQuery") + "/" + license_plate.uppercased())!
    
//    print(url)

    var returnedData = ReturnCarQuery()
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        
        if (String(data: data, encoding: .utf8)?.contains("500 Internal Server Error") == true) {
            returnedData.error = "Internal server error (500)"
            return returnedData
        }
        
        let resultObject = try JSONSerialization.jsonObject(with: data, options: [.allowFragments,])
//        print("\(resultObject)")
        
        return initCarQuery(dataCuccli: data)
    } catch {
        print("Invalid data")
        
        returnedData.error = error.localizedDescription
        return returnedData
    }
}

func initCarQuery(dataCuccli: Data) -> ReturnCarQuery {
    var decodedData: CarQueryResponse
    var returnedData = ReturnCarQuery()
    
    do {
        decodedData = try JSONDecoder().decode(CarQueryResponse.self, from: dataCuccli)
                    
        if (decodedData.status == "success") {
            print("status (Cars): \(decodedData.status)")
            returnedData.queriedCar = decodedData.message![0]
            return returnedData
        } else {
            print("Failed response: \(decodedData.error ?? "No error message from server")")
            returnedData.error = decodedData.error ?? "No error message from server"
            return returnedData
        }

    } catch {
        print("initCarQuery error: \(error)")
        returnedData.error = error.localizedDescription
//        returnedData.queriedCar = [errorCar]
        return returnedData
    }
}


//MARK: Brands
func loadBrands() async -> (brands: [Brand]?, error: String?) {
    if !brandsLoaded {
        let url = getURL(whichUrl: "brands")
        
        do {
            // (data, metadata)-ban metadata most nem kell, ezért lehet _
            let (data, _) = try await URLSession.shared.data(from: url)
            
            return initBrand(dataCuccli: data)
        } catch {
            print("Invalid data")
            return (nil, "Invalid data")
        }
    }
    print("Brands are already loaded")
    return (nil, nil)
}

//func loadBrand(license_plate: String) async -> [Brand] {
//    let url = URL(string: getURLasString(whichUrl: "brands") + "/" + license_plate.uppercased())!
//    print(url)
//
//    do {
//        let (data, _) = try await URLSession.shared.data(from: url)
//
//        return initBrand(dataCuccli: data)
//    } catch {
//        print("Invalid data")
//    }
//    return [Brand(brand_id: 1, brand: "ERROR")]
//}

func initBrand(dataCuccli: Data) -> (brands: [Brand]?, error: String?) {
    var decodedData: Response
    do {
        decodedData = try JSONDecoder().decode(Response.self, from: dataCuccli)
            
        if (decodedData.success) {
            print("status (Brand): \(decodedData.success)")
            brandsLoaded = true
            return (decodedData.brands!, nil)
        } else {
            print("Failed response: \(String(describing: decodedData.message))")
            return (nil, String(describing: decodedData.message))
        }

    } catch {
        print(error.localizedDescription)
        return (nil, error.localizedDescription)
    }
}

