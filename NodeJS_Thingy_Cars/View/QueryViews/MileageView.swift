//
//  MileageView.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 5/21/23.
//

import SwiftUI
import Charts

struct MileageView: View {
    
    @State var mileageData: [Mileage]
    
    var body: some View {
        VStack(spacing: 15) {
            Chart(mileageData) {
                BarMark(
                    x: .value("he", $0.mileageDate),
                    y: .value("he", $0.mileage)
                )
                .cornerRadius(5)
            }
            .padding()
        }
    }
}

// TODO: Change parameter order
struct MileageView_Previews: PreviewProvider {
    static var previews: some View {
        MileageView(mileageData: [
            Mileage(mileage: 127973, mileageDate: "2012.10.17."),
            Mileage(mileage: 147050, mileageDate: "2013.06.18."),
            Mileage(mileage: 249246, mileageDate: "2014.09.25."),
            Mileage(mileage: 260900, mileageDate: "2017.04.25."),
            Mileage(mileage: 302876, mileageDate: "2019.04.26."),
            Mileage(mileage: 355278, mileageDate: "2021.04.13."),
            Mileage(mileage: 456294, mileageDate: "2023.03.20.")
        ])
    }
}
