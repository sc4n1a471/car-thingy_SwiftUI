//
//  ContentView2.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/7/22.
//

import SwiftUI

struct ContentView2: View {
    @State private var results = [Car]()
    @State private var selectedCar: Car? = nil
    
    @State var newCar = Car(license_plate: "", brand_id: 1, brand: "", model: "", codename: "", year: 0, comment: "", is_new: 1, car_location: CarLocation(lo: 20.186523048482677, la: 46.229014679521015))
    
    var body: some View {
        Text("he")
    }
    
//    func loadData() async {
//        let url = getURL(whichUrl: "cars")
////        print("URL: \(url)")
//
//        do {
//            // (data, metadata)-ban metadata most nem kell, ezért lehet _
//            let (data, _) = try await URLSession.shared.data(from: url)
//
////            print("data: \(String(describing: String(data: data, encoding: .utf8)))")
//
//            initData(dataCuccli: data)
//        } catch {
//            print("Invalid data")
//        }
//    }
    
//    func initData(dataCuccli: Data) {
//        var decodedData: Response
//        do {
//            decodedData = try JSONDecoder().decode(Response.self, from: dataCuccli)
//
////            print("decodedData: \(decodedData)")
//
//            if (decodedData.status == "success") {
//                print("status: \(decodedData.status)")
////                results = decodedData.message
////                for result in results {
////                    result.setLP(lp: result.license_plate)
////                }
//            } else {
//                print("Failed response: \(decodedData.message)")
//            }
//
//        } catch {
//            print(error)
//        }
//
//    }
}

struct ContentView2_Previews: PreviewProvider {
    static var previews: some View {
        ContentView2()
    }
}
