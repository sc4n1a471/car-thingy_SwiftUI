//
//  NodeJS_Thingy_CarsApp.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 6/30/22.
//

import SwiftUI

@main
struct NodeJS_Thingy_CarsApp: App {
    var body: some Scene {
        WindowGroup {
            #if os(iOS)
            TabView {
                QueryView()
                    .tabItem {
                        Label("Query Car", systemImage: "magnifyingglass")
                    }
                ContentView()
                    .tabItem {
                        Label("My Cars", systemImage: "tray.full")
                    }
            }
            
            #elseif os(macOS)
            ContentView2()
            #endif
        }
    }
}
