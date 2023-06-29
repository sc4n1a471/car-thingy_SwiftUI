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
            HStack {
                VStack(alignment: .leading) {
                    Text("Mileage")
                        .font(.footnote)
                        .foregroundColor(Color.gray)
                    Text("\(mileageData.last?.mileage ?? 0) km")
                        .font(.title2)
                        .bold()
                    Text("\(calculateAvgMileage(_:mileageData)) km / year")
                        .font(.footnote)
                        .foregroundColor(Color.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            
            Chart(mileageData, id: \.id) { data in
                PointMark(
                    x: .value("Year", data.getDate()),
                    y: .value("Mileage", data.mileage)
                )
                LineMark(
                    x: .value("Year", data.getDate()),
                    y: .value("Mileage", data.mileage)
                )
                .interpolationMethod(.catmullRom)
            }
            .frame(height: 250)
            .padding(.leading)
        }
    }
    
    func calculateAvgMileage(_ mileageData: [Mileage]) -> Int {
        if let firstData = mileageData.first, let lastData = mileageData.last {
            let mileageDelta = lastData.mileage - firstData.mileage
            let yearDelta = lastData.getYear() - firstData.getYear()
            
            if yearDelta == 0 {
                return 0
            }
            
            return Int(mileageDelta / yearDelta)
        }
        return 0
    }
}

struct MileageView_Previews: PreviewProvider {
    static var previews: some View {
        MileageView(mileageData: testCar.mileage!)
    }
}
