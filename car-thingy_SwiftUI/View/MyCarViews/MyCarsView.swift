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
    @Environment(SharedViewData.self) private var sharedViewData

    @State private var searchCar = String()
	@State private var openDetailViewAfterUpload = false
	@State private var path: NavigationPath = NavigationPath()
    
    var body: some View {
        // required because can't use environment as binding
        @Bindable var sharedViewDataBindable = sharedViewData
        
        NavigationStack(path: $path.animation()) {
            List(searchCars) { car in
				NavigationLink(value: car, label: {
					VStack(alignment: .leading) {
						Text(car.getLP())
							.font(.headline)
						HStack {
							Text(getHeading(resultCar:car))
						}
					}
				})
            }
            .task {
				await sharedViewData.loadViewData()
            }
            .navigationTitle("My Cars")
			.navigationDestination(for: Car.self) { selectedCar in
				DetailView(selectedCar: selectedCar, region: selectedCar.getLocation())
			}
			.navigationDestination(isPresented: $openDetailViewAfterUpload) {
				DetailView(selectedCar: sharedViewData.returnNewCar, region: sharedViewData.returnNewCar.getLocation())
			}
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading, content: {
                    
                    Link(destination:
                        URL(string:"https://magyarorszag.hu/jszp_szuf")!
                    ) {
                        Image(systemName: "link")
                    }
                    
                    if sharedViewData.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        refreshButton
                    }
                })
                
                ToolbarItemGroup(placement: .navigationBarTrailing, content: {
                    plusButton
                })
            }            
            .refreshable {
				await sharedViewData.loadViewData(true)
            }
            .searchable(text: $searchCar)
			.alert(sharedViewData.error ?? "sharedViewData.error is a nil??", isPresented: $sharedViewDataBindable.showAlert) {
				Button("Got it") {
					print("alert confirmed")
				}
			}
			.sheet(isPresented: $sharedViewDataBindable.isNewCarPresented, onDismiss: {
				Task {
					await sharedViewData.loadViewData()
					if sharedViewData.returnNewCar.license_plate.license_plate != String() {
						openDetailViewAfterUpload = true
					}
				}
			}) {
				NewCar(isUpload: true)
			}
			.animation(.default, value: sharedViewData.cars)
        }
    }
    
	// MARK: Button views
    var plusButton: some View {
        Button (action: {
            sharedViewData.isNewCarPresented.toggle()
        }, label: {
            Image(systemName: "plus.circle.fill")
        })
    }
    
    var refreshButton: some View {
        Button(action: {
            Task {
				await sharedViewData.loadViewData(true)
            }
        }, label: {
            Image(systemName: "arrow.clockwise")
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
            } else if self.searchCar.localizedStandardContains("for testing purposes") {
                return sharedViewData.cars.filter {
                    $0.license_plate.comment.lowercased().contains("for testing purposes") || $0.license_plate.comment.lowercased().contains("for testing purpuses")
                }
            }
            return sharedViewData.cars.filter {
                $0.license_plate.license_plate.contains(self.searchCar.uppercased())
                ||
                $0.specs.brand!.contains(self.searchCar.uppercased())
                ||
                $0.specs.model!.contains(self.searchCar.uppercased())
                ||
                $0.specs.type_code!.contains(self.searchCar.uppercased())
            }
        }
    }
    
	// MARK: Functions
    func getHeading(resultCar: Car) -> String {
        if (resultCar.specs.brand != String()) {
            if (resultCar.specs.model == String()) {
                return resultCar.specs.type_code ?? "No type_code"
            } else {
                if (resultCar.specs.model!.contains(resultCar.specs.brand!)) {
                    return resultCar.specs.model?.replacingOccurrences(of: "\(resultCar.specs.brand!) ", with: "") ?? "No model"
                } else {
                    return resultCar.specs.model ?? "No model"
                }
            }
        } else {
            return "Unknown car!"
        }
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

#Preview {
	MyCarsView()
		.environment(SharedViewData())
}
