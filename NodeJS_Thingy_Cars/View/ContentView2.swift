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
    
    @State var newCar = Car(license_plate: "", brand: "", model: "", codename: "", year: 0, comment: "", is_new: 1)
    
    var body: some View {
        NavigationSplitView {
            
            List(results, id: \.license_plate) { car in
                
                NavigationLink {
//                    CarDetails(car: car, isNew: true)
                } label: {
                    VStack(alignment: .leading) {
                        Text(car.getLP())
                            .font(.headline)
                        HStack {
                            Text(car.brand)
                            Text(car.model)
                            Text(car.codename)
                        }
                    }
                    
                }
                .navigationSplitViewColumnWidth(min: 200, ideal: 200)
            }
            .task {
                await loadData()
            }
            .navigationTitle("Cars")
            .toolbar {
                ToolbarItem {
                    Button {
                        TestView(ezLenniCar: newCar)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        } detail: {
            DetailView(selectedCar: $selectedCar)
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
//                results = decodedData.message
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

struct ContentView2_Previews: PreviewProvider {
    static var previews: some View {
        ContentView2()
    }
}
