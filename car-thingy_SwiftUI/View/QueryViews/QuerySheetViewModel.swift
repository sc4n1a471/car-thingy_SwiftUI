//
//  QuerySheetViewModel.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 10/30/23.
//

import Foundation

extension QuerySheetView {
    @Observable class ViewModel {
            //    @State var queriedCar: CarQuery
        var isRestrictionsExpanded = false
        var isAccidentsExpanded = false
        var showingPopover = false
        var inspectionsOnly = false
        var enableScrollView = false
        
        func setPopover(_ newState: Bool) {
            self.showingPopover = newState
        }
        
        func saveCar(websocket: Websocket, knownCarQuery: Bool = true, locationManager: LocationManager) async -> Bool {
            var saveCar: Car = Car(
				licensePlate: websocket.license_plate,
				createdAt: Date.now.ISO8601Format(),
				updatedAt: Date.now.ISO8601Format(),
				brand: websocket.brand,
				color: websocket.color,
				engineSize: websocket.engine_size,
				firstReg: websocket.first_reg,
				firstRegHun: websocket.first_reg_hun,
				fuelType: websocket.fuel_type,
				gearbox: websocket.gearbox,
				model: websocket.model,
				numOfOwners: websocket.num_of_owners,
				performance: websocket.performance,
				status: websocket.status,
				typeCode: websocket.type_code,
				year: websocket.year,
				accidents: websocket.accidents,
                restrictions: websocket.restrictions,
                mileage: parseMileage(websocket.mileage, websocket.license_plate),
				inspections: []
            )
			
			var _: [Inspection] = []
			for inspection in websocket.inspections {
				saveCar.inspections?.append(
					Inspection(
						licensePlate: inspection.licensePlate,
						name: inspection.name,
						imageLocation: inspection.imageLocation
					)
				)
			}
            
            if !knownCarQuery {
                saveCar.licensePlate = websocket.license_plate
				print(locationManager.lastLocation)
				saveCar.latitude = locationManager.lastLocation.coordinate.latitude
				saveCar.longitude = locationManager.lastLocation.coordinate.longitude
				print("Saving car with coordinates... (\(saveCar.latitude), \(saveCar.longitude))")
				
				if saveCar.latitude == 40.748443 && saveCar.longitude == -73.985650 {
					print("Coordinates were default values")
					websocket.showAlert(.querySheetView, "Coordinates are pointing to Empire State Building...")
					return false
				}
            }
            
            let (safeMessage, safeError) = await saveData(uploadableCarData: saveCar, isPost: true, lpOnly: false)
            
            if let safeMessage {
                print(safeMessage)
				websocket.isQuerySaved = true
                return true
            }
            
            if let safeError {
                websocket.showAlert(.querySheetView, safeError)
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
