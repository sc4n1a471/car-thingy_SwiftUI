//
//  SpecView.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/4/23.
//

import SwiftUI

struct SpecView: View {
	@Environment(SharedViewData.self) private var sharedViewData

    var header: String
    var content: String?
    var contentInt: Int?
    var note: String?
    var accidents: [Accident]?
    var restrictions: [Restriction]?
	var isDate: Bool = false
    private var showElement: Bool
    
    /// SpecView is used for showing individual data of a car
    ///
    /// - Parameters:
    ///   - header: String as header of the element
    ///   - content: String content to be shown (for Int, use contentInt)
    ///   - contentInt: Int content to be shown (for str, use regular content)
    ///   - note: Note at the end of the line, used mostly for unit of measurment like HP or cm3
    ///   - accidents: Array of accidents shown in custom view
    ///   - restrictions: Array of restrictions shown in custom view
    init(header: String, content: String? = nil, contentInt: Int? = nil, note: String? = nil, accidents: [Accident]? = nil, restrictions: [Restriction]? = nil) {
        self.header = header
        self.content = content
        self.contentInt = contentInt
        self.note = note
        self.accidents = accidents
        self.restrictions = restrictions
		
		if self.header == "First registration" || self.header == "First registration in 🇭🇺" {
			self.isDate = true
		}
        
        if let safeAccidents = self.accidents {
            if safeAccidents.count != 0 {
                showElement = true
                return
            }
        }
        
        if let safeRestrictions = self.restrictions {
            if safeRestrictions.count != 0 {
                showElement = true
                return
            }
        }
        
        if let safeContentInt = self.contentInt {
            self.content = String(safeContentInt)
        }
		
		if self.content == "" {
			showElement = false
			return
		}
        
		if self.content != nil {
            showElement = true
            return
        }
        
        showElement = false
    }
    
    var body: some View {
        if showElement {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    // MARK: Header
                    Text(header)
                        .font(.footnote)
                        .foregroundColor(Color.gray)
                    HStack {
                        // MARK: Content
                        if let safeContent = self.content {
							if isDate {
								Text(sharedViewData.parseDate(safeContent).formatted(
									Date.FormatStyle()
										.year()
										.month()
										.day()
								))
									.font(.system(size: 22)).bold()
								Text(note ?? "")
									.font(.body.bold())
									.foregroundColor(Color.gray)
									.padding(.top, 2)
							} else {
								Text(safeContent)
									.font(.system(size: 22)).bold()
								Text(note ?? "")
									.font(.body.bold())
									.foregroundColor(Color.gray)
									.padding(.top, 2)
							}
                        // MARK: Accident
                        } else if let safeAccidents = self.accidents {
                            VStack {
								ForEach(Array(safeAccidents.enumerated()), id: \.offset) { index, accident in
                                    HStack {
										Text(sharedViewData.parseDate(accident.accidentDate).formatted(
											Date.FormatStyle()
												.year()
												.month()
												.day()
										))
                                            .font(.system(size: 22)).bold()
										
                                        Text(accident.role)
                                            .font(.body.bold())
                                            .foregroundColor(Color.gray)
                                            .padding(.top, 2)
                                    }
									.frame(maxWidth: .infinity, alignment: .leading)
									
									if index < safeAccidents.count - 1 {
										Divider()
									}
                                }
                            }
                        // MARK: Restriction
                        } else if let safeRestrictions = self.restrictions {
                            VStack {
								ForEach(Array(safeRestrictions.enumerated()), id: \.offset) { index, item in
									Text(item.restriction.lowercased().capitalizedSentence)
										.font(.system(size: 22))
										.bold()
										.frame(maxWidth: .infinity, alignment: .leading)
									
									if index < safeRestrictions.count - 1 {
										Divider()
									}
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(.default, value: content)
                .animation(.default, value: accidents)
            }
        }
    }
}

extension String {
	var capitalizedSentence: String {
		let firstLetter = self.prefix(1).capitalized
		let remainingLetters = self.dropFirst().lowercased()
		return firstLetter + remainingLetters
	}
}

// MARK: Preview
#Preview {
//	SpecView(header: "Performance", content: "320", note: "HP")
//	SpecView(header: "Restrictions", restrictions: [
//		Restriction(license_plate: "AAA111", restriction: "HEEEEE", restriction_date: "2021.01.01."),
//		Restriction(license_plate: "AAA111", restriction: "HEEEEEEEE", restriction_date: "2021.01.01.")
//	])
	SpecView(header: "Accidents", accidents: testCar.accidents)
		.environment(SharedViewData())
}
