//
//  View2.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/3/22.
//

import SwiftUI

struct View2: View {
    let car: Cars
    
    
    var body: some View {
        List {
//            Section {
//                Text(car.getLP())
//            } header: {
//                Text("License plate")
//            }
            
            Text(car.brand)
            Text(car.model)
            if (car.hasCodename) {
                Text(car.codename ?? "Default cuccli")
            }
            
            if (car.hasYear) {
                Section {
                    Text(String(car.year ?? 0))
                } header: {
                    Text("Year")
                }
            }
            
            if (car.hasComment) {
                Section {
                    Text(car.comment ?? "")
                } header: {
                    Text("Comment")
                }
            }
            
        }.navigationTitle(car.getLP())
    }
}

//struct View2_Previews: PreviewProvider {
//    static var previews: some View {
//        let test_car = Cars(license_plate: "AAA111", brand: "BMW", model: "M2")
//        View2(car: test_car)
//    }
//}
