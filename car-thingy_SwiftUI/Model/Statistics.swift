//
//  Statistics.swift
//  car-thingy_SwiftUI
//
//  Created by Martin Terhes on 9/29/24.
//

import Foundation

struct StatisticsResponse: Decodable {
	var status: String
	var data: Statistics?
	var message: String?
}

struct Statistics: Decodable {
	var carCount: Int
	var knownCars: Int
	var unknownCars: Int
	var brandStats: [BrandStatistics]
	
	func calculateRangesFilterBrandStats(_ countCutoffStepper: Int) -> ( [(brand: String, range: Range<Double>)], [BrandStatistics] ) {
		// MARK: Filter brands that have more than 5 cars
		var filteredBrandStats: [BrandStatistics] = []
		
		for brandStat in brandStats {
			if brandStat.count > countCutoffStepper {
				filteredBrandStats.append(brandStat)
			}
		}
		
		// MARK: Calculate brand ranges for piechart
		var total = 0
		
		var brandRanges: [(brand: String, range: Range<Double>)] = []
		for brandStat in filteredBrandStats {
			if brandStat.count > countCutoffStepper {
				let newTotal = total + brandStat.count
				let result = (brand: brandStat.brand,
							  range: Double(total) ..< Double(newTotal))
				total = newTotal
				brandRanges.append(result)
			}
		}
		return (brandRanges, filteredBrandStats)
	}
}

struct BrandStatistics: Decodable, Equatable {
	static func == (lhs: BrandStatistics, rhs: BrandStatistics) -> Bool {
		return lhs.brand == rhs.brand && lhs.count == rhs.count && lhs.models == rhs.models
	}
	
	var brand: String
	var count: Int
	var models: [ModelStatistics]?
}

struct ModelStatistics: Decodable, Equatable {
	var model: String
	var count: Int
}

struct CarCountData: Identifiable {
	let id = UUID()
	let status: String
	let count: Int
}
