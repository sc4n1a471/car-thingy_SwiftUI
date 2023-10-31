//
//  QueryViewModel.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 10/30/23.
//

import Foundation

extension QueryView {
    @MainActor class ViewModel: ObservableObject {
        @Published private var showingPopover: Bool = false
        @Published private var percentage: Double = 0.0
    }
}
