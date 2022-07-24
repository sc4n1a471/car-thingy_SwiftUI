//
//  View2.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/3/22.
//

import SwiftUI

struct CarDetails: View {
    let car: Car
    @State var isNewCarPresented = false
    
    var body: some View {
        List {
//            Section {
//                Text(car.getLP())
//            } header: {
//                Text("License plate")
//            }
            
            Section {
                Text(String(car.brand))
            } header: {
                Text("Brand")
            }
            
            Section {
                Text(String(car.model))
            } header: {
                Text("Model")
            }
            
            if (car.hasCodename) {
                Section {
                    Text(String(car.codename ?? "No codename was provided"))
                } header: {
                    Text("Codename")
                }
            }
            
            if (car.hasYear) {
                Section {
                    Text(String(car.year ?? 1901))
                } header: {
                    Text("Year")
                }
            }
            
            if (car.hasComment) {
                Section {
                    Text(car.comment ?? "No comment was provided")
                } header: {
                    Text("Comment")
                }
            }
            
        }
        .navigationTitle(car.getLP())
#if os(iOS)
        .navigationBarItems(trailing: editButton)
#endif
        .sheet(isPresented: $isNewCarPresented) {
            NewCar(isPresented: isNewCarPresented, isUpdate: true, isUpload: false, ezLenniCar: car)
        }
    }
    
    var editButton: some View {
        Button (action: {
            isNewCarPresented.toggle()
        }, label: {
            Image(systemName: "pencil")
        })
    }
}

//struct View2_Previews: PreviewProvider {
//    static var previews: some View {
//        let test_car = Cars(license_plate: "AAA111", brand: "BMW", model: "M2")
//        View2(car: test_car)
//    }
//}
