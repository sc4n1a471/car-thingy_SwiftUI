//
//  DetailView.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/7/22.
//

import SwiftUI

struct DetailView: View {
    @Binding var selectedCar: Car?
    
    var body: some View {
        if let car = selectedCar {
            if (car.is_new == 1) {
//                CarDetails(car: car, isNew: true)
            } else {
//                CarDetails(car: car, isNew: false)
            }            
        } else {
            Text("Select a car?")
        }
    }
}
