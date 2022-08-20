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
    @State var year: String
    @State var is_new: Bool = true
    @State var ezLenniCar: Car
    @State var showAlert = false
    
//    @State var brands = [Brand]()
    @State var brands: [Brand]
    @State var selectedBrand: Int
    @State var isNewBrand = false
    
    let removableCharacters: Set<Character> = ["-"]
    
    var textBindingLicensePlate: Binding<String> {
            Binding<String>(
                get: {
                    return self.ezLenniCar.license_plate
                    
            },
                set: { newString in
                    self.ezLenniCar.license_plate = newString.uppercased()
                    self.ezLenniCar.license_plate.removeAll(where: {
                        removableCharacters.contains($0)
                    })
            })
    }
    
    var textBindingBrand: Binding<String> {
            Binding<String>(
                get: {
                    if (self.ezLenniCar.brand == "DEFAULT_VALUE") {
                        return ""
                    }
                    return self.ezLenniCar.brand
                    
            },
                set: { newString in
                    self.ezLenniCar.brand = newString
            })
    }
    
    var textBindingModel: Binding<String> {
            Binding<String>(
                get: {
                    if (self.ezLenniCar.model == "DEFAULT_VALUE") {
                        return ""
                    }
                    return self.ezLenniCar.model
                    
            },
                set: { newString in
                    self.ezLenniCar.model = newString
            })
    }
    
    var textBindingCodename: Binding<String> {
            Binding<String>(
                get: {
                    if (self.ezLenniCar.codename == "DEFAULT_VALUE") {
                        return ""
                    }
                    return self.ezLenniCar.codename
                    
            },
                set: { newString in
                    self.ezLenniCar.codename = newString
            })
    }
    
    var textBindingYear: Binding<String> {
            Binding<String>(
                get: {
                    if Int(self.year) == 1901 {
                        return ""
                    }
                    return self.year
            },
                set: { newString in
                    self.year = newString
            })
    }
    
    var textBindingComment: Binding<String> {
            Binding<String>(
                get: {
                    if self.ezLenniCar.comment == "DEFAULT_VALUE" {
                        return ""
                    }
                    return self.ezLenniCar.comment
            },
                set: { newString in
                    self.ezLenniCar.comment = newString
            })
    }
    
    var body: some View {
        
        NavigationView {
            Form {
                Section {
                    TextField("License Plate", text: textBindingLicensePlate)
                } header: {
                    Text("License Plate")
                }
                
                Toggle("Unknown car", isOn: $is_new)
                if !is_new {
                    Section {
                        Toggle("Unknown brand", isOn: $isNewBrand)
                        if isNewBrand {
                            TextField("Brand", text: textBindingBrand)
                        } else {
                            Picker("Brand", selection: $selectedBrand) {
                                ForEach(brands, id: \.brand_id) { brand in
                                    Text(brand.brand)
                                }
                            }
                        }
                    } header: {
                        Text("Brand")
                    }
                    
                    Section {
                        TextField("Model", text: textBindingModel)
                    } header: {
                        Text("Model")
                    }
                    
                    Section {
                        TextField("Codename", text: textBindingCodename)
                    } header: {
                        Text("Codename")
                    }
                    
                    Section {
                        TextField("Year", text: textBindingYear)
                            .keyboardType(.decimalPad)
                    } header: {
                        Text("Year")
                    }
                    
                    Section {
                        TextField("Comment", text: textBindingComment)
                    } header: {
                        Text("Comment")
                    }
                }
            }.alert("Error", isPresented: $showAlert, actions: {
                Button("Got it") {
                    showAlert = false
                }
            }, message: {
                Text("Could not connect to server!")
            })
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
                if (!isNewBrand) {
                    for brand in brands {
                        if (brand.brand_id == selectedBrand) {
                            ezLenniCar.brand = brand.brand
                        }
                    }
                }
                print(ezLenniCar.brand)
                
                ezLenniCar.year = Int(year) ?? 1901
                if (is_new) {
                    ezLenniCar.is_new = 1
                } else {
                    ezLenniCar.is_new = 0
                }
                
                let successfullyUploaded = await saveData(uploadableCar: ezLenniCar, isUpload: isUpload, isUpdate: isUpdate)
                
                if successfullyUploaded {
                    isPresented = false
                    presentationMode.wrappedValue.dismiss()
                    print("Success: Upload")
                } else {
                    showAlert = true
                    print("Failed: Upload")
                }
                presentationMode.wrappedValue.dismiss()
                print(ezLenniCar)
            }
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
}

//struct NewCar_Previews: PreviewProvider {
//    static var previews: some View {
//        NewCar(isPresented: false, license_plate: "AAA111", brand: "BMW", model: "M5", codename: "E60", year: 2007, comment: "Nice")
//    }
//}
