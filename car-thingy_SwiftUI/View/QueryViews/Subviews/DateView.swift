//
//  DateView.swift
//  car-thingy_SwiftUI
//
//  Created by Martin Terhes on 11/26/23.
//

import SwiftUI

struct DateView: View {
	var licensePlate: LicensePlate
	var mapView: Bool
	private var createdAt: String = String()
	private var updatedAt: String = String()
	private var dateFormat = Date.FormatStyle(date: .long, time: .shortened)
	@State private var showPopover: Bool = false
	
	init(licensePlate: LicensePlate, mapView: Bool = true) {
		self.licensePlate = licensePlate
		self.mapView = mapView
		
		dateFormat.timeZone = TimeZone(secondsFromGMT: 7200)!
		
		if let safeDate = self.licensePlate.getDate(.updatedAt) {
			updatedAt = "Updated: \(safeDate.formatted(dateFormat))"
		} else {
			updatedAt = "Updated: Never"
		}
		
		if let safeDate = self.licensePlate.getDate(.createdAt) {
			createdAt = "Created: \(safeDate.formatted(dateFormat))"
		} else {
			createdAt = "Created: Never"
		}
	}
	
    var body: some View {
		Button(action: {
			showPopover = true
		}) {
			if mapView {
				Image(systemName: "info.circle")
					.foregroundStyle(.gray)
			} else {
				Image(systemName: "info.circle.fill")
			}
		}.popover(isPresented: $showPopover) {
			VStack {
				Text(createdAt)
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding()
				Divider()
				Text(updatedAt)
					.frame(maxWidth: .infinity, alignment: .leading)
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
    }
}

#Preview {
	DateView(licensePlate: previewCar.license_plate, mapView: false)
}
