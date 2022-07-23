//
//  TestView.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/16/22.
//

import SwiftUI

struct TestView: View {
    @State var ezLenniCar: Car
    var body: some View {
        Form {
//            Section {
//                TextField("License Plate", text: $ezLenniCar.license_plate)
//            } header: {
//                Text("License Plate")
//            }
            TextField("License Plate", text: $ezLenniCar.license_plate)
            TextField("Brand", text: $ezLenniCar.brand)
            TextField("Model", text: $ezLenniCar.model)
            TextField("Codename", text: textBindingCodename)
//            TextField("Year", text: $year)
            TextField("Comment", text: textBindingComment)
        }
        
        .toolbar {
            ToolbarItem {
                Button {
                    leading
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    var textBindingCodename: Binding<String> {
            Binding<String>(
                get: {
                    return self.ezLenniCar.codename ?? ""
            },
                set: { newString in
                    self.ezLenniCar.codename = newString
            })
    }
    
    var textBindingComment: Binding<String> {
            Binding<String>(
                get: {
                    return self.ezLenniCar.comment ?? ""
            },
                set: { newString in
                    self.ezLenniCar.comment = newString
            })
    }
    
    var leading: some View {
        Button(action: {
            Task {
                await save()
            }
//            presentationMode.wrappedValue.dismiss()
            print(ezLenniCar)
        }, label: {
            Text("Save")
        })
    }
    
    func save() async {
        guard let encoded = try? JSONEncoder().encode(ezLenniCar) else {
            print("Failed to encode order")
            return
        }
        
        let url = getURL()
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        do {
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            print(data)
//            isPresented = false
        } catch {
            print("Checkout failed.")
        }
        
        
    }
}

//struct TestView_Previews: PreviewProvider {
//    static var previews: some View {
//        TestView()
//    }
//}
