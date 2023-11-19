//
//  SpecView.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 7/4/23.
//

import SwiftUI

struct SpecView: View {
    var header: String
    var content: String?
    var note: String?
    var contents: [String]?
    var accidents: [Accident]?
    var restrictions: [Restriction]?
    private var showElement: Bool
    
    init(header: String, content: String? = nil, note: String? = nil, contents: [String]? = nil, accidents: [Accident]? = nil, restrictions: [Restriction]? = nil) {
        self.header = header
        self.content = content
        self.note = note
        self.contents = contents
        self.accidents = accidents
        self.restrictions = restrictions
        
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
                            Text(safeContent)
                                .font(.system(size: 22)).bold()
                            Text(note ?? "")
                                .font(.body.bold())
                                .foregroundColor(Color.gray)
                                .padding(.top, 2)
                        } else if let safeAccidents = self.accidents {
                            VStack {
                                ForEach(safeAccidents, id: \.self) { accident in
                                    HStack {
                                        Text(accident.accident_date)
                                            .font(.system(size: 22)).bold()
                                        Text(accident.role)
                                            .font(.body.bold())
                                            .foregroundColor(Color.gray)
                                            .padding(.top, 2)
                                    }
                                }
                            }
                        } else if let safeRestrictions = self.restrictions {
                            VStack {
                                ForEach(safeRestrictions, id: \.id) { item in
                                    HStack {
                                        Text(item.restriction)
                                            .font(.system(size: 22)).bold()
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

struct SpecView_Previews: PreviewProvider {
    static var previews: some View {
        SpecView(header: "Performance", content: "320", note: "HP")
    }
}
