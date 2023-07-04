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
    
    var body: some View {
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
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct SpecView_Previews: PreviewProvider {
    static var previews: some View {
        SpecView(header: "Performance", content: "320", note: "HP")
    }
}
