//
//  ContentView.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 6/30/22.
//

import SwiftUI
//import Foundation

//final class Car: Codable {
//    enum CodingKeys: CodingKey {
//        case license_plate
//        case brand
//        case model
//        case codename
//        case year
//        case comment
//    }
//
//    @Published var license_plate = "AAA111"
//    @Published var brand = "Default Brand"
//    @Published var model = "Default Model"
//    @Published var codename = "Default Codename"
//    @Published var year = 1900
//    @Published var comment = "Default Comment"
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        license_plate = try container.decode(String.self, forKey: .license_plate)
//        brand = try container.decode(String.self, forKey: .brand)
//        model = try container.decode(String.self, forKey: .model)
//        codename = try container.decode(String.self, forKey: .codename)
//        year = try container.decode(Int.self, forKey: .year)
//        comment = try container.decode(String.self, forKey: .comment)
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//
//        try container.encode(license_plate, forKey: .license_plate)
//        try container.encode(brand, forKey: .brand)
//        try container.encode(model, forKey: .model)
//        try container.encode(codename, forKey: .codename)
//        try container.encode(year, forKey: .year)
//        try container.encode(comment, forKey: .comment)
//    }
//}

//struct Test {
//    var name: String
//    var id = UUID()
//}

struct ContentView: View {
    @State private var results = [Cars]()

    var body: some View {
        
        NavigationView {
            
            List(results, id: \.license_plate) { car in
                
                NavigationLink {
                    View2(car: car)
                } label: {
                    VStack(alignment: .leading) {
                        Text(car.getLP())
                            .font(.headline)
                        HStack {
                            Text(car.brand)
                            Text(car.model)
                            Text(car.codename ?? "")
                        }
                    }
                    
                }
            }
            .task {
                await loadData()
            }
            .navigationTitle("Cars")
        }
    }
    
    func loadData() async {
        let url = getURL()
//        print("URL: \(url)")
        
        do {
            // (data, metadata)-ban metadata most nem kell, ezért lehet _
            let (data, _) = try await URLSession.shared.data(from: url)
            
//            print("data: \(String(describing: String(data: data, encoding: .utf8)))")
            
            initData(dataCuccli: data)
        } catch {
            print("Invalid data")
        }
    }
    
    func initData(dataCuccli: Data) {
        var decodedData: Response
        do {
            decodedData = try JSONDecoder().decode(Response.self, from: dataCuccli)
                
//            print("decodedData: \(decodedData)")
                
            if (decodedData.status == "success") {
                print("status: \(decodedData.status)")
                results = decodedData.message
//                for result in results {
//                    result.setLP(lp: result.license_plate)
//                }
            } else {
                print("Failed response: \(decodedData.message)")
            }
    
        } catch {
            print(error)
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
