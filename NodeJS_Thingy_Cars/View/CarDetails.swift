//
//  View2.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/3/22.
//

import SwiftUI

struct CarDetails: View {
    @State var car: Car
    @State var isEditCarPresented = false
    @State var isNew: Bool?
    @State var brands: [Brand]
    
    var body: some View {
        List {
            if car.hasBrand {
                Section {
                    Text(String(car.brand))
                } header: {
                    Text("Brand")
                }
            }
            
            if car.hasModel {
                Section {
                    Text(String(car.model))
                } header: {
                    Text("Model")
                }
            }
            
            
            if car.hasCodename {
                Section {
                    Text(String(car.codename))
                } header: {
                    Text("Codename")
                }
            }
            
            if car.hasYear {
                Section {
                    Text(String(car.year))
                } header: {
                    Text("Year")
                }
            }
            
            if car.hasComment {
                Section {
                    Text(car.comment)
                } header: {
                    Text("Comment")
                }
            }
        }
        .task {
            car = await loadCar(license_plate: car.license_plate).cars[0]
        }
        .navigationTitle(car.getLP())
#if os(iOS)
        .navigationBarItems(trailing: editButton)
#endif
        .sheet(isPresented: $isEditCarPresented, onDismiss: {
            Task {
                car = await loadCar(license_plate: car.license_plate).cars[0]
                brands = await loadBrands()
            }
        }) {
            NewCar(isPresented: isEditCarPresented, isUpdate: true, isUpload: false, year: String(car.year), is_new: car.isNew(), ezLenniCar: self.$car, brands: brands, selectedBrand: car.brand_id, oldLicensePlate: car.license_plate)
        }
    }
    
    var editButton: some View {
        Button (action: {
            isEditCarPresented.toggle()
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
