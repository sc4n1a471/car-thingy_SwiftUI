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
    var note: String?
    var contents: [String]?
    var accidents: [Accident]?
    var restrictions: [Restriction]?
	var isDate: Bool = false
    private var showElement: Bool
    
	init(header: String, content: String? = nil, note: String? = nil, contents: [String]? = nil, accidents: [Accident]? = nil, restrictions: [Restriction]? = nil) {
        self.header = header
        self.content = content
        self.note = note
        self.contents = contents
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
		
		if self.content == "" {
			showElement = false
			return
		}
        
		if self.content != nil {
            showElement = true
            return
        }
        
        if self.contents != nil {
            showElement = true
            return
        }
        showElement = false
    }
    
    var body: some View {
        if showElement {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(header)
                        .font(.footnote)
                        .foregroundColor(Color.gray)
                    HStack {
                        if let safeContets = self.contents {
                            VStack {
                                ForEach(safeContets, id: \.self) { item in
                                    HStack {
                                        Text(item)
                                            .font(.system(size: 22)).bold()
                                        Text(note ?? "")
                                            .font(.body.bold())
                                            .foregroundColor(Color.gray)
                                            .padding(.top, 2)
                                    }
                                }
                            }
                        } else if let safeContent = self.content {
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
                .animation(.default, value: contents)
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

#Preview {
//	SpecView(header: "Performance", content: "320", note: "HP")
//	SpecView(header: "Restrictions", restrictions: [
//		Restriction(license_plate: "AAA111", restriction: "HEEEEE", restriction_date: "2021.01.01."),
//		Restriction(license_plate: "AAA111", restriction: "HEEEEEEEE", restriction_date: "2021.01.01.")
//	])
	SpecView(header: "Accidents", accidents: testCar.accidents)
		.environment(SharedViewData())
}
