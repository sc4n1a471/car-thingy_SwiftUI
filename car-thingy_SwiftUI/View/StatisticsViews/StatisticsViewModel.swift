//
//  StatisticsViewModel.swift
//  car-thingy_SwiftUI
//
//  Created by Martin Terhes on 9/29/24.
//

import Foundation

extension StatisticsView {
	@Observable class ViewModel {
		var statistics: Statistics?
		var sharedViewData: SharedViewData?
		var isLoading: Bool = false
		
		func initViewModel(_ sharedViewData: SharedViewData) {
			self.sharedViewData = sharedViewData
		}
		
		func loadStats(_ refresh: Bool = false) async {
			self.isLoading = true
			let (stats, error) = await loadStatistics(refresh)
			
			if let stats {
				statistics = stats
			}
			
			if let error {
					// TODO: error dialog
			}
			self.isLoading = false
		}
	}
}
