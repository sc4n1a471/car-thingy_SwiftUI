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
    }
}
