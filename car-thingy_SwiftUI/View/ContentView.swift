//
//  ContentView.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 6/30/22.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject var sharedViewData = SharedViewData()
    @StateObject var querySharedData = QuerySharedData()
        
    var body: some View {
        VStack {
            #if os(iOS)
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
            .environmentObject(querySharedData)
            .environmentObject(sharedViewData)
            
            
            #elseif os(macOS)
//            ContentView2()
            #endif
        }
//        .sheet(isPresented: $querySharedData.isQueriedCarLoaded, onDismiss: {
//            Task {}
//        }) {
//            QuerySheetView(queriedCar: querySharedData.queriedCar!)
//        }
        
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
//            .environmentObject(QuerySharedData())
    }
}
