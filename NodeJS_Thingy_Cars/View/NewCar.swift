//
//  NewCar.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/8/22.
//

import SwiftUI

struct NewCar: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var isPresented: Bool
    @State var isUpdate: Bool
    @State var isUpload: Bool
//    @Binding var license_plate: String
//    @Binding var brand: String
//    @Binding var model: String
//    @Binding var codename: String?
//    @Binding var year: Int?
//    @Binding var comment: String?
    
    @State var ezLenniCar: Car
    
    var textBindingCodename: Binding<String> {
            Binding<String>(
                get: {
                    return self.ezLenniCar.codename ?? ""
            },
                set: { newString in
                    self.ezLenniCar.codename = newString
            })
    }
    
    var textBindingYear: Binding<Int> {
            Binding<Int>(
                get: {
                    return self.ezLenniCar.year ?? 1901
            },
                set: { newString in
                    self.ezLenniCar.year = newString
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
    
    var body: some View {
        
        NavigationView {
            Form {
                Section {
                    TextField("License Plate", text: $ezLenniCar.license_plate)
                } header: {
                    Text("License Plate")
                }
                
                Section {
                    TextField("Brand", text: $ezLenniCar.brand)
                } header: {
                    Text("Brand")
                }
                
                Section {
                    TextField("Model", text: $ezLenniCar.model)
                } header: {
                    Text("Model")
                }
                
                Section {
                    TextField("Codename", text: textBindingCodename)
                } header: {
                    Text("Model")
                }
                
//                Section {
//                    TextField("Year", number: textBindingYear)
//                } header: {
//                    Text("Year")
//                }
                
                Section {
                    TextField("Comment", text: textBindingComment)
                } header: {
                    Text("Comment")
                }
            }
//            .navigationBarItems(trailing: leading)
            
            #if os(iOS)
                .navigationBarItems(trailing: save)
                .navigationBarItems(leading: close)
            #endif
            }
    }
    
    
    var save: some View {
        Button(action: {
            Task {
                await saveData()
            }
            presentationMode.wrappedValue.dismiss()
            print(ezLenniCar)
        }, label: {
            Text("Save")
        })
    }
    
    var close: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Close")
        })
    }
    
    func saveData() async {
        guard let encoded = try? JSONEncoder().encode(ezLenniCar) else {
            print("Failed to encode order")
            return
        }
        
        var url: URL
        url = isUpload ? getURL() : URL(string: getURLasString() + "/" + ezLenniCar.license_plate.uppercased())!
//        if isUpload {
//            url = getURL()
//        } else {
//            url = URL(string: getURLasString() + "/" + ezLenniCar.license_plate.uppercased())!
//        }
        
        var request = URLRequest(url: url)
                
        request.httpMethod = isUpload ? "POST" : "PUT"
        
//        if isUpload {
//            request.httpMethod = "POST"
//        } else {
//            request.httpMethod = "PUT"
//        }
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            print(String(data: data, encoding: .utf8))
            isPresented = false
        } catch {
            print("Checkout failed.")
        }
    }
}

//struct NewCar_Previews: PreviewProvider {
//    static var previews: some View {
//        NewCar(isPresented: false, license_plate: "AAA111", brand: "BMW", model: "M5", codename: "E60", year: 2007, comment: "Nice")
//    }
//}
