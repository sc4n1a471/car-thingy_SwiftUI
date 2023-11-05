//
//  MyCarsView.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/8/23.
//

import SwiftUI

enum HapticType: String {
    case notification
    case standard
    case error
}

struct MyCarsView: View {
    @EnvironmentObject var sharedViewData: SharedViewData
    @EnvironmentObject var querySharedData: QuerySharedData

    @State private var searchCar = String()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(searchCars, id: \.id) { resultCar in
                    NavigationLink {
                        DetailView(selectedCar: resultCar, region: resultCar.getLocation())
                    } label: {
                        VStack(alignment: .leading) {
                            Text(resultCar.getLP())
                                .font(.headline)
                            HStack {
                                if (resultCar.specs.brand != String()) {
                                    Text(resultCar.specs.model ?? "No model")
                                    Text(resultCar.specs.type_code ?? "No type_code")
                                } else {
                                    Text("New car!")
                                }
                            }
                        }
                    }
                }
                .onDelete { IndexSet in
                    Task {
                        let (unsafeCars, unsafeError) = try await deleteData(at: IndexSet, cars: sharedViewData.cars)
                        
                        if let safeCars = unsafeCars {
                            sharedViewData.cars = safeCars
                            haptic()
                        }
                        
                        if let safeError = unsafeError {
                            sharedViewData.error = safeError
                            sharedViewData.showAlert = true
                            haptic(type: .error)
                        }
                    }
                }
            }
            .task {
                await loadViewData()
            }
            .navigationTitle("My Cars")
            
            #if os(iOS)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading, content: {
                    
                    Link(destination:
                        URL(string:"https://magyarorszag.hu/jszp_szuf")!
                    ) {
                        Image(systemName: "link")
                    }
                    
                    Button(action: {
                        Task {
                            await loadViewData(true)
                        }
                    }, label: {
                        Image(systemName: "arrow.clockwise")
                    })
                })
                
                ToolbarItemGroup(placement: .navigationBarTrailing, content: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .isHidden(!sharedViewData.isLoading)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .isHidden(!querySharedData.isLoading)
                    
                    plusButton
                        .disabled(sharedViewData.isLoading)
                })
            }
            #endif
            
            .refreshable {
                await loadViewData(true)
            }
            .searchable(text: $searchCar)
        }
        .alert(sharedViewData.error ?? "sharedViewData.error is a nil??", isPresented: $sharedViewData.showAlert) {
            Button("Got it") {
                print("alert confirmed")
            }
        }
        .sheet(isPresented: $sharedViewData.isNewCarPresented, onDismiss: {
            Task {
                await loadViewData()
            }
        }) {
            NewCar(isUpload: true)
        }
    }
    
    var plusButton: some View {
        Button (action: {
            sharedViewData.isNewCarPresented.toggle()
        }, label: {
            Image(systemName: "plus.circle.fill")
        })
    }
    
    var searchCars: [Car] {
        if searchCar.isEmpty {
            return sharedViewData.cars
        } else {
            if self.searchCar.localizedStandardContains("new") {
                return sharedViewData.cars.filter {
                    $0.specs.brand == String()
                }
            }
            return sharedViewData.cars.filter {
                $0.license_plate.license_plate.contains(self.searchCar.uppercased())
//                ||
//                (($0.specs.brand?.localizedStandardContains(self.searchCar)) != nil) ||
//                (($0.specs.model?.localizedStandardContains(self.searchCar)) != nil) ||
//                (($0.specs.type_code?.localizedStandardContains(self.searchCar)) != nil)
            }
        }
    }
    
    func loadViewData(_ refresh: Bool = false) async {
        sharedViewData.isLoading = true
        let (safeCars, safeCarError) = await loadCars(refresh)
        if let safeCars {
            withAnimation {
                sharedViewData.cars = safeCars
            }
        }
        
        if let safeCarError {
            sharedViewData.error = safeCarError
            sharedViewData.showAlert = true
            haptic(type: .error)
        }
        
        sharedViewData.isLoading = false
    }
    
    func haptic(type: HapticType = .standard, intensity: CGFloat = 0.5) {
        print("Haptic")
        switch type {
        case .standard:
            let impact = UIImpactFeedbackGenerator()
            impact.prepare()
            impact.impactOccurred(intensity: intensity)
        case .notification:
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.success)
        case .error:
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.error)
        }
    }
}

struct MyCarsView_Previews: PreviewProvider {
    static var previews: some View {
        MyCarsView()
    }
}
