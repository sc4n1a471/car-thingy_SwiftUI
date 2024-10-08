//
//  InspectionView.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 6/30/23.
//

import SwiftUI

struct InspectionView: View {
    @Environment(\.presentationMode) var presentationMode
	@Environment(SharedViewData.self) private var sharedViewData

    var inspection: Inspection

    @State private var presentSheet = false
    @State private var imageIndex: Int = 0
    
    var body: some View {
        VStack {
            VStack(alignment: .center) {
				Text(inspection.parseName(.name))
                    .font(.footnote)
                    .foregroundColor(Color.gray)
				Text(sharedViewData.parseDate(inspection.parseName(.date)).formatted(
					Date.FormatStyle()
						.year()
						.month()
						.day()
				))
                    .font(.title2)
                    .bold()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            
            TabView {
                ForEach(0..<(inspection.base64?.count ?? 0), id:\.self) { i in
                    if let safeImage = convertImage(base64: inspection.base64![i]) {
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
            .padding(.bottom, 20)
            .padding(.trailing, 20)
            .padding(.leading, 20)
            .shadow(radius: 10)
        }
        .sheet(isPresented: $presentSheet, onDismiss: {
            Task {}
        }) {
            InspectionImageViewer(imageIndex: imageIndex, images: inspection.base64!)
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

#Preview {
    InspectionView(inspection: testCar.inspections![0])
}
