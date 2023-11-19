//
//  InspectionsView.swift
//  car-thingy_SwiftUI
//
//  Created by Martin Terhes on 11/12/23.
//

import SwiftUI

struct InspectionsView: View {
    var inspections: [Inspection]
    
    var body: some View {
        if inspections.count != 0 {
            Section {
                if inspections.count == 1 {
                    ForEach(inspections, id: \.self) { inspection in
                        Section {
                            InspectionView(inspection: inspection)
                                .frame(width: 351, height: 300)
                        }
                        .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                } else {
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(inspections, id: \.self) { inspection in
                                VStack {
                                    InspectionView(inspection: inspection)
                                        .frame(width: 250, height: 250)
                                }
                                .cornerRadius(10)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .safeAreaPadding(.horizontal, 55)
                    .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
            }
        }
    }
}


#Preview {
    InspectionsView(inspections: testCar.inspections!)
}
