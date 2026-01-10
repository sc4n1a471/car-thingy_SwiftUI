//
//  StatisticsView.swift
//  car-thingy_SwiftUI
//
//  Created by Martin Terhes on 9/29/24.
//

import SwiftUI
import Charts

struct StatisticsView: View {
	
	@State private var viewModel = ViewModel()
	@State private var selectedAngle: Double?
	@State private var countCutoffStepper: Int = 10
	@State private var brandRanges: [(brand: String, range: Range<Double>)] = []
	@State private var filteredBrandStats: [BrandStatistics] = []
	
	var carData: [CarCountData] {
		[
			CarCountData(status: "Known Cars", count: viewModel.statistics?.knownCars ?? 0),
			CarCountData(status: "Unknown Cars", count: viewModel.statistics?.unknownCars ?? 0)
		]
	}
	
	var selectedItem: BrandStatistics? {
		guard let selectedAngle else { return nil }
		let ranges = brandRanges
		if let selected = ranges.firstIndex(where: {
			$0.range.contains(selectedAngle)
		}) {
			return filteredBrandStats[selected]
		}
		return nil
	}
	
    // MARK: Body
    var body: some View {
		NavigationStack {
			VStack {
				if let safeCarStatistics = viewModel.statistics {
					ScrollView {
						VStack(spacing: 20) {
							VStack {
								Text("Car count")
									.font(.headline)
									.foregroundColor(.gray)
								Text("\(safeCarStatistics.carCount)")
									.font(.largeTitle)
									.fontWeight(.bold)
							}
							.frame(maxWidth: .infinity)
							
							// MARK: Bar chart
							Chart(carData) { data in
								BarMark(
									x: .value("Car Type", data.count)
								)
								.foregroundStyle(by: .value("Status", data.status))
								.cornerRadius(10)
							}
							.padding()
							.frame(maxWidth: .infinity)
							.chartXScale(domain: 0...safeCarStatistics.carCount)
							
							// MARK: Pie chart
							Chart(filteredBrandStats, id: \.brand) { item in
								SectorMark(
									angle: .value("Count", item.count),
									innerRadius: .ratio(0.6),
									angularInset: 1.5
								)
								.cornerRadius(6)
								.foregroundStyle(by: .value("Brand", item.brand))
								.opacity(item.brand == selectedItem?.brand ? 0.7 : 1)
							}
							.scaledToFit()
							.chartLegend(Visibility.hidden)
							.padding()
							.chartAngleSelection(value: $selectedAngle)
							.chartBackground { chartProxy in
								GeometryReader { geometry in
									if let anchor = chartProxy.plotFrame {
										let frame = geometry[anchor]
										VStack {
											Text(selectedItem?.brand ?? "Brands")
												.font(.title2)
											Text((selectedItem?.count.formatted() ?? safeCarStatistics.carCount.formatted()) + " cars")
												.font(.callout)
										}
										.position(x: frame.midX, y: frame.midY)
									}
								}
							}
							.animation(.snappy, value: filteredBrandStats)
                            
                            Stepper(value: $countCutoffStepper, label: {
                                Text("Brand count cutoff value: \(countCutoffStepper)")
                            })
                            .padding()
                            .onChange(of: countCutoffStepper) { oldValue, newValue in
                                (brandRanges, filteredBrandStats) = (viewModel.statistics?.calculateRangesFilterBrandStats(newValue))!
                            }
						}
						.padding(.top)
					}
				} else {
					VStack {
						Text("No statistics available yet.")
							.bold()
					}
				}
			}
			.navigationTitle("Statistics")
			.navigationBarTitleDisplayMode(.large)
            // MARK: Toolbar
			.toolbar {
				ToolbarItemGroup(placement: .topBarLeading, content: {
					if viewModel.isLoading {
						ProgressView()
							.progressViewStyle(CircularProgressViewStyle())
					} else {
						refreshButton
					}
                })
			}
		}
        // MARK: Task
		.task {
			await viewModel.loadStats()
			(brandRanges, filteredBrandStats) = (viewModel.statistics?.calculateRangesFilterBrandStats(countCutoffStepper))!
		}
    }
	
    // MARK: Refresh button
	var refreshButton: some View {
		Button(action: {
			Task {
				await viewModel.loadStats(true)
				(brandRanges, filteredBrandStats) = (viewModel.statistics?.calculateRangesFilterBrandStats(countCutoffStepper))!
			}
		}, label: {
            Image(systemName: "arrow.clockwise.circle")
		})
	}
}

// MARK: Preview
#Preview {
    StatisticsView()
}
