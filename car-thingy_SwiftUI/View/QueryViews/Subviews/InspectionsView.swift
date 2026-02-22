//
//  InspectionsView.swift
//  car-thingy_SwiftUI
//
//  Created by Martin Terhes on 11/12/23.
//

import SwiftUI

struct InspectionsView: View {
	@Environment(SharedViewData.self) private var sharedViewData
	
    var inspections: [Inspection]?
    
    var body: some View {
        if let safeInspections = inspections {
            if safeInspections.count != 0 {
                Section {
                    // MARK: Single version
                    if safeInspections.count == 1 {
                        ForEach(safeInspections, id: \.name) { inspection in
                            Section {
                                InspectionView(inspection: inspection)
                                    .frame(width: 351, height: 300)
                            }
                            .listRowInsets(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .safeAreaPadding(.horizontal, 55)
                        }
                    } else {
                        // MARK: Multiple version
                        ScrollView(.horizontal) {
                            LazyHStack {
                                ForEach(safeInspections.sorted {
                                    let parsedDate1 = sharedViewData.parseDate($0.parseName(.date))
                                    let parsedDate2 = sharedViewData.parseDate($1.parseName(.date))
                                    return parsedDate1 > parsedDate2
                                }, id: \.name) { inspection in
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
}


// MARK: Previews
#Preview {
	InspectionsView(inspections: previewCar.inspections!)
		.environment(SharedViewData())
}

/// https://stackoverflow.com/questions/77336072/how-to-create-preview-with-async-code-in-swiftui
//#Preview("Custom car") {
//    struct AsyncTestView: View {
//        @State var car: Car = previewCar
//        
//        var body: some View {
//            InspectionsView(inspections: car.inspections)
//                .environment(SharedViewData())
//                .task {
//                    print("Downloading custom car...")
//                    let (safeCar, _) = await loadCar(license_plate: "THF516")
//                    if let safeCar {
//                        car = safeCar[0]
//                        print("Downloaded \(car.inspections!.count) inspections")
//                    }
//                }
//        }
//    }
//    
//    return AsyncTestView()
//}

//#Preview {
//	DetailView(
//		selectedCar: previewCar,
//		region: previewCar.getLocation()
//	)
//		.environment(SharedViewData())
//}
