//
//  ContentView.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 6/30/22.
//

import SwiftUI
//import Foundation

//struct Test {
//    var name: String
//    var id = UUID()
//}

struct ContentView: View {
    @State private var results = [Car]()
    @State var isNewCarPresented = false
    @State var isLoading = false
    @State var searchCar = ""
    
    @State var newCar = Car(license_plate: "", brand: "", model: "")

    var body: some View {
        
        NavigationView {
            
            List {
                
                ForEach(results, id: \.license_plate) { result in
                    NavigationLink {
                        CarDetails(car: result)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(result.getLP())
                                .font(.headline)
                            HStack {
    //                            Text(car.brand)
                                Text(result.model)
                                Text(result.codename ?? "")
                            }
                        }
                    }
                }
                .onDelete { IndexSet in
                    Task {
                        await deleteData(at: IndexSet)
                    }
                }
            }
            .task {
                await loadData()
            }
            .navigationTitle("Cars")
            
#if os(iOS)
            .navigationBarItems(trailing: plusButton)
#endif
            
            .refreshable {
                await loadData()
            }
            .searchable(text: $searchCar)
            
        }
        .sheet(isPresented: $isNewCarPresented) {
            NewCar(isPresented: isNewCarPresented, ezLenniCar: newCar)
        }
        if isLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
        }
    }
    
    var plusButton: some View {
        Button (action: {
            isNewCarPresented.toggle()
        }, label: {
            Image(systemName: "plus")
        })
    }
    
//    var searchCars: [Cars] {
//        if searchCar.isEmpty {
//            return results
//        } else {
//            return results.filter {
//                $0.contains(searchCars)
//            }
//        }
//    }
    
    func deleteCar() async {
        
    }
               
//    func didDismiss() async {
//        print(newCar)
//    }
    
    func loadData() async {
        let url = getURL()
//        print("URL: \(url)")
        
        do {
            self.isLoading = true
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
                results = decodedData.data!
//                for result in results {
//                    result.setLP(lp: result.license_plate)
//                }
            } else {
                print("Failed response: \(decodedData.message)")
            }
    
        } catch {
            print(error)
        }
        self.isLoading = false
    }
    
    func deleteData(at offsets: IndexSet) async {
        
//        print(offsets.first!)
//        print(results)
//        print(results[offsets.first!].license_plate)
        
        let url1 = getURLasString() + "/" + (results[offsets.first!].license_plate).uppercased()
        let urlFormatted = URL(string: url1)
        var request = URLRequest(url: urlFormatted!)
        print(urlFormatted!)
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
//            print("data: \(data)")

            do {
                var decodedData: Response
                decodedData = try JSONDecoder().decode(Response.self, from: data)
                print(decodedData.message as Any)
            } catch {
                print("Error: Trying to convert JSON data to string")
                print(error)
                return
            }
            results.remove(atOffsets: offsets)
        }.resume()
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
