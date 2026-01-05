//
//  QuerySheetViewModel.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 10/30/23.
//

import Foundation

extension QuerySheetView {
    @Observable class ViewModel {
        var isRestrictionsExpanded = false
        var isAccidentsExpanded = false
        var showingPopover = false
        var inspectionsOnly = false
        var enableScrollView = false
        
        func setPopover(_ newState: Bool) {
            self.showingPopover = newState
        }
        
        func saveCar(socketioObject: Socketio, knownCarQuery: Bool = true, locationManager: LocationManager) async -> Bool {
            var saveCar: Car = Car(
                licensePlate: socketioObject.car.licensePlate,
				comment: socketioObject.car.comment,
				createdAt: Date.now.ISO8601Format(),
				updatedAt: Date.now.ISO8601Format(),
				brand: socketioObject.car.brand,
				color: socketioObject.car.color,
				engineSize: socketioObject.car.engineSize,
				firstReg: socketioObject.car.firstReg,
				firstRegHun: socketioObject.car.firstRegHun,
				fuelType: socketioObject.car.fuelType,
				gearbox: socketioObject.car.gearbox,
				model: socketioObject.car.model,
				numOfOwners: socketioObject.car.numOfOwners,
				performance: socketioObject.car.performance,
				status: socketioObject.car.status,
				typeCode: socketioObject.car.typeCode,
				year: socketioObject.car.year,
				accidents: socketioObject.car.accidents,
                restrictions: socketioObject.car.restrictions,
                mileage: parseMileage(socketioObject.car.mileage, socketioObject.car.licensePlate),
				inspections: []
            )
			
            if let safeInspections = socketioObject.car.inspections {
                for inspection in safeInspections {
                    saveCar.inspections?.append(
                        Inspection(
                            licensePlate: inspection.licensePlate,
                            name: inspection.name,
                            imageLocation: inspection.imageLocation
                        )
                    )
                }
            }
            
            if !knownCarQuery && env != "local" && env != "dev" {
                saveCar.licensePlate = socketioObject.car.licensePlate
				print(locationManager.lastLocation)
				saveCar.latitude = locationManager.lastLocation.coordinate.latitude
				saveCar.longitude = locationManager.lastLocation.coordinate.longitude
				print("Saving car with coordinates... (\(saveCar.latitude), \(saveCar.longitude))")
            }
            
            let (safeMessage, safeError) = await saveData(uploadableCarData: saveCar, isPost: true)
            
            if let safeMessage {
                print(safeMessage)
                return true
            }
            
            if let safeError {
                socketioObject.showAlert(.querySheetView, safeError)
                return false
            }
            return false
        }
        
        func parseMileage(_ oldMileage: [Mileage], _ licensePlate: String) -> [Mileage] {
            var newMileage: [Mileage] = []
            for mileage in oldMileage {
                newMileage.append(Mileage(
                    mileage: mileage.mileage,
                    date: mileage.date,
                    licensePlate: licensePlate
                ))
            }
            return newMileage
        }
    }
}
