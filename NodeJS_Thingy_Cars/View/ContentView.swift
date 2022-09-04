//
//  ContentView.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 6/30/22.
//

import SwiftUI

struct ContentView: View {
    @State private var results = ReturnCar()
    @State private var isNewCarPresented = false
    @State private var isLoading = false
    @State private var searchCar = ""
    @State private var brands = [Brand]()
    
    @State var newCar = Car(license_plate: "", brand_id: 1, brand: "", model: "", codename: "", year: 0, comment: "", is_new: 1)

    @State var showAlert = false
    
    var body: some View {
        
        if isLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
        } else {
            NavigationView {
                
                List {
                    
                    ForEach(searchCars, id: \.license_plate) { result in
                        NavigationLink {
                            CarDetails(car: result, brands: brands)
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
                            print(0)
//                            DispatchQueue.main.async {
//                                print(0.1)
//                                results = await deleteData(at: IndexSet, cars: results.cars)
//                            }
                            results = try await deleteData(at: IndexSet, cars: results.cars)
//                            print(results)
                            if (results.error != "DEFAULT_VALUE") {
                                print("error delete")
                                showAlert = true
                            }
                        }
                    }
                }
                .task {
                    results = await loadData()
                    if (results.error != "DEFAULT_VALUE") {
                        showAlert = true
                    }
                    brands = await loadBrands()
                }
                .navigationTitle("Cars")
                
                #if os(iOS)
                 
                .navigationBarItems(trailing: plusButton)
                .navigationBarItems(leading:
                    Link(destination:
                        URL(string:"https://magyarorszag.hu/jszp_szuf")!) {
                            Image(systemName: "link")
                        }
                )
                .navigationBarItems(leading:
                    Button(action: {
                        Task {
                            results = await loadData()
                            if (results.error != "DEFAULT_VALUE") {
                                showAlert = true
                            }
                            brands = await loadBrands()
                        }
                    }, label: {
                    Image(systemName: "arrow.clockwise")
                    })
                )
                #endif
                
                .refreshable {
                    results = await loadData()
                    if (results.error != "DEFAULT_VALUE") {
                        showAlert = true
                    }
                    brands = await loadBrands()
                }
                .searchable(text: $searchCar)
            }
            .alert(results.error, isPresented: $showAlert, actions: {
                Button("Got it") {
                    print("alert confirmed")
                }
            })
            .sheet(isPresented: $isNewCarPresented, onDismiss: {
                Task {
                    results = await loadData()
                    if (results.error != "DEFAULT_VALUE") {
                        showAlert = true
                    }
                    brands = await loadBrands()
                    newCar = Car(license_plate: "", brand_id: 1, brand: "", model: "", codename: "", year: 0, comment: "", is_new: 1)
                }
            }) {
                NewCar(isPresented: isNewCarPresented, isUpdate: false, isUpload: true, year: "", is_new: true, ezLenniCar: self.$newCar, brands: brands, selectedBrand: 1)
            }
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
            return results.cars
        } else {
            if self.searchCar.localizedStandardContains("new") {
                return results.cars.filter {
                    $0.is_new == 1
                }
            }
            return results.cars.filter {
                $0.license_plate.contains(self.searchCar.uppercased()) ||
                $0.brand.localizedStandardContains(self.searchCar) ||
                $0.model.localizedStandardContains(self.searchCar)
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
