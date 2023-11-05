//
//  QuerySheetViewModel.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 10/30/23.
//

import Foundation

extension QuerySheetView {
    @MainActor class ViewModel: ObservableObject {
            //    @State var queriedCar: CarQuery
        @Published var isRestrictionsExpanded = false
        @Published var isAccidentsExpanded = false
        @Published var showingPopover = false
        @Published var inspectionsOnly = false
        @Published var enableScrollView = false
        
        func setPopover(_ newState: Bool) {
            self.showingPopover = newState
        }
        
        func saveCar(websocket: Websocket) async -> Bool {
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
                restrictions: parseRestrictions(websocket.restrictions, websocket.license_plate),
                mileage: parseMileage(websocket.mileage, websocket.license_plate)
            )
            
            return await saveData(uploadableCarData: saveCar, isPost: true, lpOnly: false)
        }
        
        func parseRestrictions(_ stringRestrictions: [String], _ licensePlate: String) -> [Restriction] {
            var newRestrictions: [Restriction] = []
            for restriction in stringRestrictions {
                newRestrictions.append(Restriction(
                    license_plate: licensePlate,
                    restriction: restriction,
                    restriction_date: Date.now.ISO8601Format(),
                    active: true
                ))
            }
            return newRestrictions
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
