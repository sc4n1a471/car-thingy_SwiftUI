//
//  InspectionView.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 6/30/23.
//

import SwiftUI

struct InspectionView: View {
    var inspection: Inspection
    @State private var inspectionDate: String = ""
    @State private var inspectionName: String = "Műszaki vizsgálat"
    
    @State private var presentSheet = false
    @State var imageIndex: Int?
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(inspectionName)
                    .font(.footnote)
                    .foregroundColor(Color.gray)
                Text(inspectionDate)
                    .font(.title2)
                    .bold()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            TabView {
                ForEach(0..<inspection.images.count, id:\.self) { i in
                    if let safeImage = convertImage(base64: inspection.images[i]) {
                        safeImage
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .onTapGesture {
                                imageIndex = i
                                presentSheet = true
                            }
                    }
                }
            }
            .cornerRadius(10)
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        }
        .onAppear() {
            Task {
                self.inspectionDate = inspection.name.replacingOccurrences(of: "MŰSZAKI VIZSGÁLAT, ", with: "")
            }
        }
        .sheet(isPresented: $presentSheet, onDismiss: {
            Task {}
        }) {
            InspectionImageViewer(imageIndex: imageIndex ?? 0, images: inspection.images)
        }
    }
    
    // MARK: base64 image converter
    /// https://developer.apple.com/forums/thread/698596
    func convertImage(base64: String) -> Image? {
        guard let stringData = Data(base64Encoded: base64),
              let uiImage = UIImage(data: stringData) else {
                  print("Error: couldn't create UIImage")
                  return nil
              }
        
        let swiftUIImage = Image(uiImage: uiImage)
        
        return swiftUIImage
    }
}

struct InspectionView_Previews: PreviewProvider {
    static var previews: some View {
//        InspectionView(inspection: testCar.inspections![0])
        QuerySheetView(queriedCar: testCar, inspectionsOnly: true)
    }
}
