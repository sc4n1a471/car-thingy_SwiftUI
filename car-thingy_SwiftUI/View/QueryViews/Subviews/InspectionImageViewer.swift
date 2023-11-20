//
//  InspectionImageViewer.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 6/30/23.
//

import SwiftUI
import LazyPager

struct InspectionImageViewer: View {
    @State var imageIndex: Int
    @State var images: [String]
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            VStack {
                LazyPager(data: images, page: $imageIndex) { element in
                    if let safeImage = convertImage(base64: element) {
                        safeImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
                .zoomable(min: 1, max: 5)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading, content: {
                    close
                })
            }
            .background(Color.black)
            .ignoresSafeArea()
        }
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
    
    var close: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Image(systemName: "xmark")
        })
    }
}

#Preview {
	InspectionImageViewer(imageIndex: 0, images: testCar.inspections![0].base_64!)
}
