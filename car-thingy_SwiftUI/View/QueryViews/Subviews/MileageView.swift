//
//  MileageView.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 5/21/23.
//

import SwiftUI
import Charts

struct MileageView: View {
    
    var onChangeMileageData: [Mileage]
    @Binding var mileageData: [Mileage]
    @State var currentActiveMileage: Mileage?
    @State var hideLabels: Bool = false
    @State private var firstHaptic: Bool = true
    
    var body: some View {
        if !mileageData.isEmpty {
            VStack(spacing: 15) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Mileage")
                            .font(.footnote)
                            .foregroundColor(Color.gray)
                        
                        HStack {
                            Text("\(mileageData.last?.mileage ?? 0)")
                                .font(.system(size: 25)).bold()
                            Text("km")
                                .font(.body.bold())
                                .foregroundColor(Color.gray)
                                .padding(.top, 2)
                        }
                        
                        withAnimation {
                            Text("\(calculateAvgMileage(mileageData)) km / year")
                                .font(.footnote)
                                .foregroundColor(Color.gray)
                                .animation(.easeIn)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .isHidden(hideLabels)
                .frame(maxHeight: 75)
                
                Chart(mileageData, id: \.id) { data in
                    PointMark(
                        x: .value("Year", data.getDate()),
                        y: .value("Mileage", data.animate ?? false ? data.mileage : 0)
                    )
                    LineMark(
                        x: .value("Year", data.getDate()),
                        y: .value("Mileage", data.animate ?? false ? data.mileage : 0)
                    )
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Year", data.getDate()),
                        y: .value("Mileage", data.animate ?? false ? data.mileage : 0)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Color.blue.opacity(0.1).gradient)
                    
                    if let currentActiveMileage, currentActiveMileage.id == data.id {
                        RuleMark(x: .value("Date", currentActiveMileage.getDate(true)))
                            .foregroundStyle(Color.gray.opacity(0.3))
                    }
                }
                .frame(height: 250)
                .padding(.leading)
                .onAppear {
                        // MARK: Animating chart
                    for (index, _) in mileageData.enumerated() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.15) {
                            withAnimation(
                                .interactiveSpring(response: 0.6, dampingFraction: 0.9, blendDuration: 0.1)) {
                                    mileageData[index].animate = true
                                }
                        }
                    }
                }
                .onChange(of: onChangeMileageData) { newMileageData in
                    if newMileageData.count != 0 {
                        if newMileageData[0].mileage_date.contains(".") {
                            mileageData = newMileageData
                            for (index, _) in mileageData.enumerated() {
                                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.15) {
                                    withAnimation(
                                        .interactiveSpring(response: 0.6, dampingFraction: 0.9, blendDuration: 0.1)) {
                                            mileageData[index].animate = true
                                        }
                                }
                            }
                        }
                    }
                }
                .chartOverlay { proxy in
                        // MARK: Getting data on drag
                        // https://developer.apple.com/documentation/charts/chartproxy
                    GeometryReader { geometry in
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let location = value.location
                                            // Get the x (date) and y (mileage) value from the location.
                                        if let date: Date = proxy.value(atX: location.x) {
                                            let calendar = Calendar.current
                                            let components = calendar.dateComponents([.year, .month], from: date)
                                            
                                            if let currentMileageData = mileageData.first(where: { item in
                                                item.getYear() == components.year
                                            }) {
                                                if let safeCurrentActiveMileage = self.currentActiveMileage {
                                                    if safeCurrentActiveMileage.mileage_date != currentMileageData.mileage_date {
                                                        firstHaptic = true
                                                    }
                                                }
                                                self.currentActiveMileage = currentMileageData
                                                withAnimation {
                                                    self.hideLabels = true
                                                }
                                                
                                                if firstHaptic {
                                                    MyCarsView().haptic()
                                                    firstHaptic = false
                                                }
                                            }
                                        }
                                    }
                                    .onEnded { value in
                                        self.currentActiveMileage = nil
                                        withAnimation {
                                            self.hideLabels = false
                                        }
                                        firstHaptic = true
                                    }
                            )
                    }
                }
                .chartBackground { proxy in
                    ZStack(alignment: .topLeading) {
                        GeometryReader { geo in
                            if let currentActiveMileage {
                                    // Find date span for the selected interval
                                let dateInterval = Calendar.current.dateInterval(of: .day, for: currentActiveMileage.getDate())!
                                    // Map date to chart X position
                                let startPositionX = proxy.position(forX: dateInterval.start) ?? 0
                                    // Offset the chart X position by chart frame
                                let midStartPositionX = startPositionX + geo[proxy.plotAreaFrame].origin.x
                                let lineHeight = geo[proxy.plotAreaFrame].maxY
                                let boxWidth: CGFloat = 150
                                let boxOffset = max(0, min(geo.size.width - boxWidth, midStartPositionX - boxWidth / 2))
                                
                                    // Draw the scan line
                                    //                            Rectangle()
                                    //                                .fill(.quaternary)
                                    //                                .frame(width: 2, height: lineHeight)
                                    //                                .position(x: midStartPositionX, y: lineHeight / 2)
                                
                                    // Draw the data info box
                                VStack(alignment: .leading) {
                                    Text("CURRENT")
                                        .font(.system(size: 14).bold())
                                        .foregroundStyle(.secondary)
                                    HStack {
                                        Text("\(currentActiveMileage.mileage)")
                                            .font(.system(size: 25)).bold()
                                        Text("km")
                                            .font(.body.bold())
                                            .foregroundColor(Color.gray)
                                    }
                                    
                                    Text("\(currentActiveMileage.getDate(), format: .dateTime.year().month().day())")
                                        .font(.system(size: 14).bold())
                                        .foregroundStyle(.secondary)
                                }
                                .frame(width: boxWidth, height: 75, alignment: .leading)
                                .background { // some styling
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.background)
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.quaternary.opacity(0.3))
                                    }
                                    .padding([.leading, .trailing], -8)
                                    .padding([.top, .bottom], -4)
                                }
                                .offset(x: boxOffset, y: -95)
                                .padding(5)
                            }
                        }
                    }
                }
            }
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

//struct MileageView_Previews: PreviewProvider {
//    static var previews: some View {
//        MileageView(mileageData: testCar.mileage!)
//    }
//}
