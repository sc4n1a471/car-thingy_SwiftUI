//
//  ContentView.swift
//  NodeJS_Thingy_Cars
//
//  Created by Martin Terhes on 6/30/22.
//

import SwiftUI
import MapKit

struct ContentView: View {
	@State private var path: NavigationPath = NavigationPath()

    var body: some View {
		NavigationStack(path: $path.animation()) {
			Text("car-thingy_SwiftUI")
				.font(.largeTitle)
				.fontWeight(.bold)
				.padding(.top, 20)
			
			NavigationLink(destination: {
				QueryView()
			}, label: {
				Label("Query Car", systemImage: "magnifyingglass")
					.contentViewStyle()
			}).padding(.bottom, 20)
			
			NavigationLink(destination: {
				MyCarsView(path: $path)
			}, label: {
				Label("My Cars", systemImage: "tray.full")
					.contentViewStyle()
			}).padding(.bottom, 20)
			
			NavigationLink(destination: {
				MapView()
			}, label: {
				Label("Map", systemImage: "map")
					.contentViewStyle()
			}).padding(.bottom, 20)
			
			Text("v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "???")")
			Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "???")
		}.toolbar(content: {
			ToolbarItemGroup(placement: .navigationBarLeading, content: {
				Link(destination:
						URL(string:"https://magyarorszag.hu/jszp_szuf")!
				) {
					Image(systemName: "link")
				}
			})
		})
		.ignoresSafeArea()
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

extension View {
		/// Applies the given transform if the given condition evaluates to `true`.
		/// - Parameters:
		///   - condition: The condition to evaluate.
		///   - transform: The transform to apply to the source `View`.
		/// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
	@ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
		if condition {
			transform(self)
		} else {
			self
		}
	}
}

extension View {
	func contentViewStyle() -> some View {
		modifier(ContentViewModifier())
	}
}

struct ContentViewModifier: ViewModifier {
	func body(content: Content) -> some View {
		content
			.font(.system(size: 25))
			.foregroundStyle(.white)
			.padding(20)
			.background(.blue)
			.clipShape(.rect(cornerRadius: 20))
			.frame(maxWidth: .infinity, maxHeight: 100)
	}
}

#Preview {
    ContentView()
        .environment(SharedViewData())
}
