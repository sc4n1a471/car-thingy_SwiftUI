//
//  InspectionsView.swift
//  car-thingy_SwiftUI
//
//  Created by Martin Terhes on 11/12/23.
//

import SwiftUI

struct InspectionsView: View {
	@Environment(SharedViewData.self) private var sharedViewData
	
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
						.safeAreaPadding(.horizontal, 55)
                    }
                } else {
                    ScrollView(.horizontal) {
                        LazyHStack {
							ForEach(inspections.sorted {
								var parsedDate1 = sharedViewData.parseDate($0.parseName(.date))
								var parsedDate2 = sharedViewData.parseDate($1.parseName(.date))
								return parsedDate1 > parsedDate2
							}, id: \.self) { inspection in
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
	InspectionsView(inspections: previewCar.inspections!)
		.environment(SharedViewData())
}

#Preview {
	DetailView(
		selectedCar: previewCar,
		region: previewCar.getLocation()
	)
		.environment(SharedViewData())
}
