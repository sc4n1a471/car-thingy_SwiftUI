//
//  ContentView.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 6/30/22.
//

import SwiftUI
import MapKit

struct ContentView: View {
    var body: some View {
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
            }
        }
    }
}

extension View {
    @ViewBuilder func isHidden(_ isHidden: Bool) -> some View {
        if isHidden {
            self.hidden()
        } else {
            self
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
