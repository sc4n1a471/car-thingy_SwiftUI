//
//  ContentView.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 6/30/22.
//

import SwiftUI

struct ContentView: View {
    @State private var results = [Car]()
    @State var isNewCarPresented = false
    @State var isLoading = false
    @State var searchCar = ""
    
    @State var newCar = Car(license_plate: "", brand: "", model: "", codename: "", year: 0, comment: "", is_new: 1)

    var body: some View {
        
        NavigationView {
            
            List {
                
                ForEach(searchCars, id: \.license_plate) { result in
                    NavigationLink {
                        CarDetails(car: result)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(result.getLP())
                                .font(.headline)
                            HStack {
                                if (result.is_new == 1) {
                                    Text("New car!")
                                } else {
                                    Text(result.model)
                                    if result.hasCodename {
                                        Text(result.codename)
                                    }
                                }
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
            NewCar(isPresented: isNewCarPresented, isUpdate: false, isUpload: true, year: "", ezLenniCar: newCar)
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
    
    var searchCars: [Car] {
        if searchCar.isEmpty {
            return results
        } else {
            return results.filter {
                $0.license_plate.contains(self.searchCar.uppercased()) ||
                $0.brand.localizedStandardContains(self.searchCar) ||
                $0.model.localizedStandardContains(self.searchCar)
            }
        }
    }
    
    func loadData() async {
        let url = getURL()
        
        do {
            self.isLoading = true
            // (data, metadata)-ban metadata most nem kell, ezért lehet _
            let (data, _) = try await URLSession.shared.data(from: url)
            
            initData(dataCuccli: data)
        } catch {
            print("Invalid data")
        }
    }
    
    func initData(dataCuccli: Data) {
        var decodedData: Response
        do {
            decodedData = try JSONDecoder().decode(Response.self, from: dataCuccli)
                
            if (decodedData.status == "success") {
                print("status: \(decodedData.status)")
                results = decodedData.data!
            } else {
                print("Failed response: \(decodedData.message)")
            }
    
        } catch {
            print(error)
        }
        self.isLoading = false
    }
    
    func deleteData(at offsets: IndexSet) async {
        
        let url1 = getURLasString() + "/" + (results[offsets.first!].license_plate).uppercased()
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
            results.remove(atOffsets: offsets)
        }.resume()
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
