//
//  ContentView.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 6/30/22.
//

import SwiftUI

struct ContentView: View {
    @State var results = [Car]()
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
                        results = await deleteData(at: IndexSet, cars: results)
                    }
                }
            }
            .task {
                results = await loadData()
            }
            .navigationTitle("Cars")
            
#if os(iOS)
            .navigationBarItems(trailing: plusButton)
#endif
            
            .refreshable {
                results = await loadData()
            }
            .searchable(text: $searchCar)
        }
        .sheet(isPresented: $isNewCarPresented, onDismiss: {
            Task {
                results = await loadData()
            }
        }) {
            NewCar(isPresented: isNewCarPresented, isUpdate: false, isUpload: true, year: "", is_new: true, ezLenniCar: newCar)
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
    
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
