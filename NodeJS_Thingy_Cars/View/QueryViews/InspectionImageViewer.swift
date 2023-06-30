//
//  InspectionImageViewer.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 6/30/23.
//

import SwiftUI

struct InspectionImageViewer: View {
    @State var imageIndex = 0
    @State var images: [String]
    
    var body: some View {
        TabView {
            ForEach(0..<images.count, id:\.self) { i in
                if let safeImage = convertImage(base64: images[i]) {
                    safeImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
    
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

struct InspectionImageViewer_Previews: PreviewProvider {
    static var previews: some View {
        InspectionImageViewer(imageIndex: 1, images: testCar.inspections![0].images)
    }
}
