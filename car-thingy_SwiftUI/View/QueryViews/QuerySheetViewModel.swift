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
                license_plate:
                    LicensePlate(
                        license_plate: websocket.license_plate,
                        created_at: Date.now.ISO8601Format()
                    ),
                accidents: websocket.accidents,
                specs: Specs(
                    license_plate: websocket.license_plate,
                    brand: websocket.brand,
                    color: websocket.color,
                    engine_size: websocket.engine_size,
                    first_reg: websocket.first_reg,
                    first_reg_hun: websocket.first_reg_hun,
                    fuel_type: websocket.fuel_type,
                    gearbox: websocket.gearbox,
                    model: websocket.model,
                    num_of_owners: websocket.num_of_owners,
                    performance: websocket.performance,
                    status: websocket.status,
                    type_code: websocket.type_code,
                    year: websocket.year
                ),
                restrictions: websocket.restrictions,
                mileage: parseMileage(websocket.mileage, websocket.license_plate)
            )
            
            if !knownCarQuery {
                saveCar.coordinates.license_plate = websocket.license_plate
				print(locationManager.lastLocation)
				saveCar.coordinates.latitude = locationManager.lastLocation?.coordinate.latitude ?? 37.789467
				saveCar.coordinates.longitude = locationManager.lastLocation?.coordinate.longitude ?? -122.416772
				print("Saving car with coordinates... (\(saveCar.coordinates.latitude), \(saveCar.coordinates.longitude))")
				
				if saveCar.coordinates.latitude == 37.789467 && saveCar.coordinates.longitude == -122.416772 {
					print("Coordinates were default values")
					websocket.showAlert(error: "Coordinates were default values")
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
                websocket.showAlert(error: safeError)
                return false
            }
            return false
        }
        
        func parseMileage(_ oldMileage: [Mileage], _ licensePlate: String) -> [Mileage] {
            var newMileage: [Mileage] = []
            for mileage in oldMileage {
                newMileage.append(Mileage(
                    mileage: mileage.mileage,
                    mileageDate: mileage.mileage_date,
                    license_plate: licensePlate
                ))
            }
            return newMileage
        }
    }
}
