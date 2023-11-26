//
//  DateView.swift
//  car-thingy_SwiftUI
//
//  Created by Martin Terhes on 11/26/23.
//

import SwiftUI

struct DateView: View {
	var licensePlate: LicensePlate
	private var createdAt: String = String()
	private var updatedAt: String = String()
	@State private var showPopover: Bool = false
	
	init(licensePlate: LicensePlate) {
		self.licensePlate = licensePlate
		
		if let safeDate = licensePlate.getDate(.updatedAt) {
			updatedAt = "Updated: \(safeDate.formatted(date: .long, time: .shortened))"
		} else {
			updatedAt = "Updated: Never"
		}
		
		if let safeDate = licensePlate.getDate(.createdAt) {
			createdAt = "Created: \(safeDate.formatted(date: .long, time: .shortened))"
		} else {
			createdAt = "Created: Never"
		}
	}
	
    var body: some View {
		Button(action: {
			showPopover = true
		}) {
			Image(systemName: "info.circle")
				.foregroundStyle(.gray)
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
		.buttonStyle(.bordered)
		.cornerRadius(55)
		.clipShape(Circle())
    }
}

#Preview {
	DateView(licensePlate: previewCar.license_plate)
}
