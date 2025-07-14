//
//  ContentView.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 6/30/22.
//

import SwiftUI
import MapKit
import CocoaLumberjackSwift

struct ContentView: View {
	@State private var expand: Bool = false
	@State private var verificationCode: String = String()
	@Environment(SharedViewData.self) private var sharedViewData
	@Environment(\.colorScheme) var colorScheme
	@Namespace var animation
	
    var body: some View {
		// required because can't use environment as binding
		@Bindable var sharedViewDataBindable = sharedViewData
		
		VStack {
			TabView {
				QueryView()
					.tabItem {
						Label("Query Car", systemImage: "magnifyingglass")
					}
				MyCarsView()
					.tabItem {
						Label("My Cars", systemImage: "tray.full")
					}
				MapView()
					.tabItem {
						Label("Map", systemImage: "map")
					}
				StatisticsView()
					.tabItem {
						Label("Statistics", systemImage: "chart.pie")
					}
			}
		}
		.ignoresSafeArea()
		.task {
			DDLog.add(DDOSLogger.sharedInstance) // Uses os_log
			let fileLogger: DDFileLogger = DDFileLogger() // File Logger
			fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
			fileLogger.logFileManager.maximumNumberOfLogFiles = 7
			DDLog.add(fileLogger)
		}
		.tabBarMinimizeBehavior(.onScrollDown)
		.tabViewBottomAccessory {
			MiniQuerySheetView(sharedViewData)
				.matchedTransitionSource(id: "mini-query-id", in: animation)
				.onTapGesture {
					sharedViewData.websocket.dataSheetOpened.toggle()
				}
		}
		.fullScreenCover(isPresented: $sharedViewDataBindable.websocket.dataSheetOpened, onDismiss: {
			Task {
				sharedViewData.websocket.dismissSheet()
			}
		}) {
			VStack(spacing: 10) {
				Spacer()
				Spacer()
				Spacer()
				Spacer()
				Capsule()
					.fill(.primary.secondary)
					.frame(width: 35, height: 3)
					.padding(.top)
				
				QuerySheetView(knownCarQuery: false)
			}
			.navigationTransition(.zoom(sourceID: "mini-query-id", in: animation))
			.ignoresSafeArea()
			.background(
				colorScheme == .dark ? .black : Color(
					.secondarySystemBackground
				)
			)
		}
    }
}

extension View {
	@ViewBuilder
	func MiniQuerySheetView(_ sharedViewData: SharedViewData) -> some View {
		if sharedViewData.showMiniQueryView {
			HStack {
				Text(
					sharedViewData.websocket.license_plate
				)
				
				if (sharedViewData.websocket.isLoading) {
					Gauge(value: sharedViewData.websocket.percentage, in: 0...100) {}
						.gaugeStyle(.accessoryCircularCapacity)
						.tint(.blue)
						.scaleEffect(0.5)
						.frame(maxWidth: 200, maxHeight: 50)
					
					Button {
						sharedViewData.websocket.close()
					} label: {
						Image(systemName: "xmark")
							.contentShape(.rect)
							.foregroundColor(.red)
					}
					.padding(.trailing)
				}
			}
			.padding(.horizontal, 15)
		}
	}
}

extension View {
		/// Applies the given transform if the given condition evaluates to `true`.
		/// - Parameters:
		///   - condition: The condition to evaluate.
		///   - transform: The transform to apply to the source `View`.
		/// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
	@ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
		if condition {
			transform(self)
		} else {
			self
		}
	}
}

extension View {
	func contentViewStyle() -> some View {
		modifier(ContentViewModifier())
	}
}

struct ContentViewModifier: ViewModifier {
	func body(content: Content) -> some View {
		content
			.font(.system(size: 25))
			.foregroundStyle(.white)
			.padding(20)
			.background(.blue)
			.clipShape(.rect(cornerRadius: 20))
			.frame(maxWidth: .infinity, maxHeight: 100)
	}
}

#Preview {
    ContentView()
        .environment(SharedViewData())
}
