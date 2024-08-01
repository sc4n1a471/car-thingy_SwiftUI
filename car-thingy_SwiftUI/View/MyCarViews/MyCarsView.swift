//
//  MyCarsView.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/8/23.
//

import SwiftUI

enum SortType: String {
	case licensePlate = "License Plate"
	case createdAt = "Created At"
}

struct MyCarsView: View {
    @Environment(SharedViewData.self) private var sharedViewData
	
	@State private var path: NavigationPath = NavigationPath()
    @State private var searchCar = String()
	@State private var openDetailViewAfterUpload = false
	@State private var sortType: SortType = .licensePlate
	var sortedCars: [Car] {
		switch sortType {
			case .licensePlate:
				return searchCars.sorted { $0.licensePlate < $1.licensePlate }
			case .createdAt:
				return searchCars.sorted { $0.parsedCreatedAt! > $1.parsedCreatedAt! }
		}
	}
	
    var body: some View {
        // required because can't use environment as binding
        @Bindable var sharedViewDataBindable = sharedViewData

		NavigationStack(path: $path.animation()) {
			List(sortedCars) { car in
				NavigationLink(destination: {
					DetailView(selectedCar: car, region: car.getLocation())
				}, label: {
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
			.navigationBarTitleDisplayMode(.large)
			.navigationTitle("My Cars")
			.navigationDestination(isPresented: $openDetailViewAfterUpload) {
				DetailView(selectedCar: sharedViewData.returnNewCar, region: sharedViewData.returnNewCar.getLocation())
			}
			.toolbar {
				ToolbarItemGroup(placement: .topBarLeading, content: {
					if sharedViewData.isLoading {
						ProgressView()
							.progressViewStyle(CircularProgressViewStyle())
					} else {
						refreshButton
					}
				})
				
				ToolbarItemGroup(placement: .topBarTrailing, content: {
					submenu
				})
				
				ToolbarItem(placement: .topBarTrailing, content: {
					Button(action: {
						sharedViewData.clearNewCar()
						sharedViewData.clearExistingCar()
						sharedViewData.isNewCarPresented.toggle()
					}, label: {
						HStack {
							Image(systemName: "plus.circle.fill")
						}
					})
					.fontWeight(.bold)
				})
			}
			.refreshable {
				await sharedViewData.loadViewData(true)
			}
			.searchable(text: $searchCar, placement: .toolbar)
			.alert(sharedViewData.error ?? "sharedViewData.error is a nil??", isPresented: $sharedViewDataBindable.showAlert) {
				Button("Got it") {
					print("alert confirmed")
				}
			}
			.sheet(isPresented: $sharedViewDataBindable.isNewCarPresented, onDismiss: {
				Task {
					await sharedViewData.loadViewData()
					if sharedViewData.returnNewCar.licensePlate != String() {
						openDetailViewAfterUpload = true
					}
				}
			}) {
				NewCar(isUpload: true)
			}
			.animation(.default, value: sharedViewData.cars)
//			.safeAreaInset(edge: .bottom, content: {
//				VStack {
//					Button(action: {
//						sharedViewData.clearNewCar()
//						sharedViewData.clearExistingCar()
//						sharedViewData.isNewCarPresented.toggle()
//					}, label: {
//						HStack {
//							Image(systemName: "plus.circle.fill")
//								.font(.system(size: 25))
//							Text("New car")
//								.font(.system(size: 18))
//						}
//					})
//					.fontWeight(.bold)
//				}
//				.frame(alignment: .bottom)
//				.frame(maxWidth: .infinity, alignment: .leading)
//				.padding()
//				.background(.ultraThickMaterial)
//			})
		}
    }
    
	// MARK: Button views
    var plusButton: some View {
        Button (action: {
			sharedViewData.clearNewCar()
			sharedViewData.clearExistingCar()
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
	
	var submenu: some View {
		Menu(content: {
			Link(destination:
				URL(string:"https://magyarorszag.hu/jszp_szuf")!
			) {
				Text("Open JSZP")
				Image(systemName: "safari")
			}
			
			Menu(content: {
				Picker("he", systemImage: "line.3.horizontal.decrease.circle", selection: $sortType, content: {
					Text("License Plate").tag(SortType.licensePlate)
					Text("Created At").tag(SortType.createdAt)
				})
			}, label: {
				Text("Sort By")
				Image(systemName: "arrow.up.arrow.down")
				Text(sortType.rawValue)
			})
		}, label: {
			Image(systemName: "ellipsis.circle")
		})
	}
    
    var searchCars: [Car] {
        if searchCar.isEmpty {
            return sharedViewData.cars
        } else {
            if self.searchCar.localizedStandardContains("new") {
                return sharedViewData.cars.filter {
                    $0.brand == nil
                }
            } else if self.searchCar.localizedStandardContains("for testing purposes") {
				return sharedViewData.cars.filter { car -> Bool in
					guard let safeComment = car.comment else { return false }
					return safeComment.lowercased().contains("for testing purposes")
                }
            }
            return sharedViewData.cars.filter { car -> Bool in
				guard let safeBrand = car.brand else { return false }
				guard let safeModel = car.model else { return false }
				guard let safeTypeCode = car.typeCode else { return false }
				return car.licensePlate.contains(self.searchCar.uppercased())
                ||
				safeBrand.contains(self.searchCar.uppercased())
                ||
				safeModel.contains(self.searchCar.uppercased())
                ||
                safeTypeCode.contains(self.searchCar.uppercased())
            }
        }
    }
    
	// MARK: Functions
    func getHeading(resultCar: Car) -> String {
        if (resultCar.brand != nil) {
            if (resultCar.model == String()) {
                return resultCar.typeCode ?? "No type_code"
            } else {
                if (resultCar.model!.contains(resultCar.brand!)) {
                    return resultCar.model?.replacingOccurrences(of: "\(resultCar.brand!) ", with: "") ?? "No model"
                } else {
                    return resultCar.model ?? "No model"
                }
            }
        } else {
            return "Unknown car!"
        }
    }
}

#Preview {
	MyCarsView()
		.environment(SharedViewData())
}
