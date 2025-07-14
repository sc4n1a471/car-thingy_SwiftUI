//
//  DateView.swift
//  car-thingy_SwiftUI
//
//  Created by Martin Terhes on 11/26/23.
//

import SwiftUI

struct DateView: View {
	var car: Car
	var mapView: Bool
	private var createdAt: String = String()
	private var updatedAt: String = String()
	private var dateFormat = Date.FormatStyle(date: .long, time: .shortened)
	@State private var showPopover: Bool = false
	
	init(car: Car, mapView: Bool = true) {
		self.car = car
		self.mapView = mapView
		
		dateFormat.timeZone = TimeZone(secondsFromGMT: 7200)!
		
		if let safeDate = self.car.getDate(.updatedAt) {
			updatedAt = "\(safeDate.formatted(dateFormat))"
		}
		
		if let safeDate = self.car.getDate(.createdAt) {
			createdAt = "\(safeDate.formatted(dateFormat))"
		}
	}
	
    var body: some View {
		Button(action: {
			showPopover = true
		}) {
			if mapView {
				Image(systemName: "calendar")
					.foregroundStyle(.gray)
			} else {
				Image(systemName: "calendar")
			}
		}.popover(isPresented: $showPopover) {
			VStack {
				VStack {
					Text(createdAt)
						.font(.system(size: 22)).bold()
						.frame(maxWidth: .infinity, alignment: .leading)
					Text("Created")
						.font(.body.bold())
						.foregroundColor(Color.gray)
				}
				.padding()
				
				Divider()
				
				VStack {
					Text(updatedAt)
						.font(.system(size: 22)).bold()
						.frame(maxWidth: .infinity, alignment: .leading)
					Text("Updated")
						.font(.body.bold())
						.foregroundColor(Color.gray)
				}
				.padding()
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.presentationCompactAdaptation(.none)
			.presentationBackground(.clear)
		}
		.if(mapView) { view in
			view
				.clipShape(Circle())
				.buttonStyle(.bordered)
		}
//		.buttonStyle(.bordered)
    }
}

#Preview {
	DateView(car: previewCar, mapView: false)
}

#Preview {
		MyCarsView()
			.environment(SharedViewData())
}
