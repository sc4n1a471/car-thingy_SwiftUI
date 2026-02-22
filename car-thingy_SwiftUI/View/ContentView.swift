//
//  ContentView.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 6/30/22.
//

import SwiftUI
import MapKit
import CocoaLumberjackSwift
import AppIntents

struct ContentView: View {
	@Environment(SharedViewData.self) private var sharedViewData
	@Environment(\.colorScheme) var colorScheme
	@Namespace private var animation
	
    // MARK: Body
    var body: some View {
		// required because can't use environment as binding
		@Bindable var sharedViewDataBindable = sharedViewData
		
		VStack {
            TabView {
                Tab("Query Car", systemImage: "icloud.and.arrow.down") {
                    QueryView()
                }
                
                Tab("My Cars", systemImage: "tray.full", role: .search) {
                    MyCarsView()
                }
                
                Tab("Map", systemImage: "map") {
                    MapView()
                }
                
                Tab("Statistics", systemImage: "chart.pie") {
                    StatisticsView()
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
        .tabViewBottomAccessory(isEnabled: sharedViewData.showMiniQueryView) {
            MiniQuerySheetView(sharedViewData)
                .matchedTransitionSource(id: "mini-query-id", in: animation)
				.onTapGesture {
					sharedViewData.socketio.dataSheetOpened.toggle()
				}
		}
		.fullScreenCover(isPresented: $sharedViewDataBindable.socketio.dataSheetOpened, onDismiss: {
			Task {
                sharedViewData.socketio.dismissSheet()
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

// MARK: IF extension, used only in DateView
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

// MARK: Mini query sheet view
struct MiniQuerySheetViewContent: View {
	let sharedViewData: SharedViewData
	@Environment(\.tabViewBottomAccessoryPlacement) var placement
	
	var body: some View {
		if sharedViewData.socketio.isLoading {
			HStack(spacing: 12) {
                Text(sharedViewData.socketio.getLP())
                    .font(placement == .inline ? .custom("custom small font size", size: 10) : .headline)
					.frame(maxWidth: .infinity, alignment: .leading)
				
				Gauge(value: sharedViewData.socketio.percentage, in: 0...100) {}
					.gaugeStyle(.accessoryCircularCapacity)
					.tint(.blue)
					.scaleEffect(0.5)
					.frame(maxWidth: 200, maxHeight: 50)
				
				Button {
					sharedViewData.socketio.cancelCarRequest()
				} label: {
					Image(systemName: "xmark")
						.contentShape(.rect)
						.foregroundColor(.red)
				}
				.frame(maxWidth: .infinity, alignment: .trailing)
			}
			.padding(.horizontal, 15)
		} else {
			HStack {
				Text(sharedViewData.socketio.getLP())
					.font(.headline)
			}
		}
	}
}

extension View {
	@ViewBuilder
    func MiniQuerySheetView(_ sharedViewData: SharedViewData) -> some View {
		MiniQuerySheetViewContent(sharedViewData: sharedViewData)
	}
}

// MARK: Preview
#Preview {
    ContentView()
        .environment(SharedViewData())
}

// MARK: AppIntent
struct NewCarIntent: AppIntent {
    static var title: LocalizedStringResource = "Add new license plate"
    static var supportedModes: IntentModes = .foreground(.dynamic)
    
    @Parameter(title: "License plate") var licensePlate: String
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let locationManager = LocationManager()
        var location: CLLocation?
        var region: MKCoordinateRegion?
        
        do {
            DDLogVerbose("AppIntent: Getting location...")
            // 1. Get the current location from the location manager
            location = try await locationManager.currentLocation
            region = locationManager.region
            DDLogVerbose("AppIntent: Got location: \(location)")
            DDLogVerbose("AppIntent: \(locationManager.region.center.latitude), \(locationManager.region.center.longitude)")
        } catch {
            DDLogError("Could not get user location: \(error.localizedDescription)")
        }
        
        var newCar: Car = Car()
        newCar.licensePlate = licensePlate.uppercased()
        newCar.latitude = region!.center.latitude
        newCar.longitude = region!.center.longitude
        
        newCar.updatedAt = Date.now.ISO8601Format()
        newCar.mileage = []
        
        newCar.createdAt = Date.now.ISO8601Format()
        
        let (safeMessage, safeError) = await saveData(uploadableCarData: newCar, isPost: true)
        
        if let safeMessage {
            DDLogVerbose("Upload was successful: \(safeMessage)")
            return .result(dialog: "Car uploaded successfully! 👍")
        }
        
        if let safeError {
            DDLogVerbose("Upload failed: \(safeError)")
            return .result(dialog: "Adding license plate failed with this error 👎: \(safeError) ")
        }
        return .result(dialog: "No safeMessage/safeError???")
    }
}

