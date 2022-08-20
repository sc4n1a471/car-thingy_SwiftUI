//
//  HTTP.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/30/22.
//

import Foundation

func loadData() async -> [Car] {
    let url = getURL(whichUrl: "cars")
    
    do {
        // (data, metadata)-ban metadata most nem kell, ezért lehet _
        let (data, _) = try await URLSession.shared.data(from: url)
        
        return initData(dataCuccli: data)
    } catch {
        print("Invalid data")
    }
    return [Car(license_plate: "ERROR", brand_id: 1, brand: "ERROR", model: "ERROR", codename: "ERROR", year: 9999, comment: "ERROR", is_new: 1)]
}

func loadCar(license_plate: String) async -> [Car] {
    let url = URL(string: getURLasString(whichUrl: "cars") + "/" + license_plate.uppercased())!
    print(url)
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        
        return initData(dataCuccli: data)
    } catch {
        print("Invalid data")
    }
    return [Car(license_plate: "ERROR", brand_id: 1, brand: "ERROR", model: "ERROR", codename: "ERROR", year: 9999, comment: "ERROR", is_new: 1)]
}

func saveData(uploadableCar: Car, isUpload: Bool, isUpdate: Bool) async -> Bool {
    guard let encoded = try? JSONEncoder().encode(uploadableCar) else {
        print("Failed to encode order")
        return false
    }
    
    var url: URL
    url = isUpload ? getURL(whichUrl: "cars") : URL(string: getURLasString(whichUrl: "cars") + "/" + uploadableCar.license_plate.uppercased())!
    
    var request = URLRequest(url: url)
            
    request.httpMethod = isUpload ? "POST" : "PUT"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    do {
        let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
        print(String(data: data, encoding: .utf8))
        return true
    } catch {
        print("Checkout failed.")
        return false
    }
}

func deleteData(at offsets: IndexSet, cars: [Car]) async -> [Car] {
    
    var cars = cars
    
    let url1 = getURLasString(whichUrl: "cars") + "/" + (cars[offsets.first!].license_plate).uppercased()
    let urlFormatted = URL(string: url1)
    var request = URLRequest(url: urlFormatted!)
    request.httpMethod = "DELETE"
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil else {
            print("Error: error calling DELETE")
            print(error!)
            return
        }
        guard let data = data else {
            print("Error: Did not receive data")
            return
        }

        do {
            var decodedData: Response
            decodedData = try JSONDecoder().decode(Response.self, from: data)
            print(decodedData.message as Any)
        } catch {
            print("Error: Trying to convert JSON data to string")
            print(error)
            return
        }
        cars.remove(atOffsets: offsets)
    }.resume()
    return cars
}

func initData(dataCuccli: Data) -> [Car] {
    var decodedData: Response
    do {
        decodedData = try JSONDecoder().decode(Response.self, from: dataCuccli)
            
        if (decodedData.status == "success") {
            print("status (Cars): \(decodedData.status)")
            return decodedData.cars!
        } else {
            print("Failed response: \(decodedData.message)")
        }

    } catch {
        print(error)
    }
    return [Car(license_plate: "ERROR", brand_id: 1, brand: "ERROR", model: "ERROR", codename: "ERROR", year: 9999, comment: "ERROR", is_new: 1)]
}


func loadBrands() async -> [Brand] {
    let url = getURL(whichUrl: "brands")
    
    do {
        // (data, metadata)-ban metadata most nem kell, ezért lehet _
        let (data, _) = try await URLSession.shared.data(from: url)
        
        return initBrand(dataCuccli: data)
    } catch {
        print("Invalid data")
    }
    return [Brand(brand_id: 1, brand: "ERROR")]
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

func initBrand(dataCuccli: Data) -> [Brand] {
    var decodedData: Response
    do {
        decodedData = try JSONDecoder().decode(Response.self, from: dataCuccli)
            
        if (decodedData.status == "success") {
            print("status (Brand): \(decodedData.status)")
            return decodedData.brands!
        } else {
            print("Failed response: \(decodedData.message)")
        }

    } catch {
        print(error)
    }
    return [Brand(brand_id: 1, brand: "ERROR")]
}

