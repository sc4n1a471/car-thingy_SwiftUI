//
    //  QueryView.swift
    //  NodeJS_Thingy_Cars
    //
    //  Created by Martin Terhes on 5/21/23.
    //

import SwiftUI

enum EnvPickerSelections: String {
	case prod = "Production"
	case dev = "Development"
	case local = "Local"
}

struct QueryView: View {
	@Environment(SharedViewData.self) private var sharedViewData
	
    @FocusState private var lpTextFieldFocused: Bool
    
    @State private var viewModel = ViewModel()
    @State private var requestedLicensePlate: String = String()
	@State private var showVersionPopover: Bool = false
	@State private var verificationCode: String = String()
	
	@State private var envPickerSelection: EnvPickerSelections = .prod
	
    let removableCharacters: Set<Character> = ["-"]
    var textBindingLicensePlate: Binding<String> {
        Binding<String>(
            get: {
                return requestedLicensePlate
                
            },
            set: { newString in
                requestedLicensePlate = newString.uppercased()
                requestedLicensePlate.removeAll(where: {
                    removableCharacters.contains($0)
                })
            })
    }
    
    var body: some View {
		// required because can't use environment as binding
		@Bindable var sharedViewDataBindable = sharedViewData
		
        NavigationStack {
            VStack(spacing: 50) {
                Section {
                    TextField("Enter requested license plate", text: textBindingLicensePlate)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .frame(maxWidth: 400)
                        .focused($lpTextFieldFocused)
                }
				
				Button {
					Task {
						lpTextFieldFocused = false
						await sharedViewData.websocket.connect(requestedLicensePlate)
					}
				} label: {
					Text("Request")
						.frame(maxWidth: 200, maxHeight: 50)
				}
//				.glassEffect(
//					.regular
//						.tint((
//							!sharedViewData.websocket.isLoading ? Color.blue : Color.gray
//						).opacity(0.35))
//						.interactive(), in: .rect(cornerRadius: 16.0)
//				)
				.buttonStyle(.borderedProminent)
                
                Button {
                    Task {
						sharedViewData.showMiniQueryView = true
                        await sharedViewData.websocket.connect("test111")
                    }
                } label: {
                    Text("Test Request")
                        .frame(maxWidth: 200, maxHeight: 50)
                }
                .disabled(sharedViewData.websocket.isLoading)
//				.glassEffect(
//					.regular
//						.tint((
//							!sharedViewData.websocket.isLoading ? Color.blue : Color.gray
//						).opacity(0.35)).interactive(),
//					in: .rect(cornerRadius: 16.0)
//				)
				.buttonStyle(.borderedProminent)
				.tint(Color.secondary)
            }
            .padding()
            .toolbar {
				ToolbarItem(placement: .topBarLeading, content: {
					Button(action: {
						showVersionPopover = true
					}) {
						Image(systemName: "info.circle")
							.foregroundStyle(.gray)
					}.popover(isPresented: $showVersionPopover) {
						VStack {
							Text("v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "???")")
								.frame(maxWidth: .infinity, alignment: .leading)
								.padding()
							
							Divider()

							Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "???")
								.frame(maxWidth: .infinity, alignment: .leading)
								.padding()
							
							Divider()
							
							Text(envPickerSelection.rawValue)
								.frame(maxWidth: .infinity, alignment: .leading)
								.padding()
						}
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.presentationCompactAdaptation(.none)
						.presentationBackground(.clear)
					}
				})
				
				ToolbarItem(placement: .topBarTrailing, content: {
					changeEnv
				})
            }
            .navigationTitle("Car Query")
			.navigationBarTitleDisplayMode(.large)
        }
        .alert(sharedViewData.websocket.error, isPresented: $sharedViewDataBindable.websocket.isAlert, actions: {
            Button("sharedViewData.websocket got it") {
                sharedViewData.websocket.disableAlert()
                print("sharedViewData.websocket alert confirmed")
            }
        })
    }
	
	var changeEnv: some View {
		Menu(content: {
			Menu(content: {
				Picker("he", systemImage: "line.3.horizontal.decrease.circle", selection: $envPickerSelection, content: {
					Text("Production").tag(EnvPickerSelections.prod)
					Text("Development").tag(EnvPickerSelections.dev)
					Text("Local").tag(EnvPickerSelections.local)
				})
				.onChange(of: envPickerSelection, {
					switch envPickerSelection {
					case .prod:
						setProd()
					case .dev:
						setDev()
					case .local:
						setLocal()
					}
				})
			}, label: {
				Text("Environment")
				Image(systemName: "server.rack")
				Text(envPickerSelection.rawValue)
			})
		}, label: {
			Image(systemName: "ellipsis.circle")
		})
	}
}

#Preview {
	QueryView()
		.environment(SharedViewData())
		.previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
		.previewDisplayName("iPhone 13 Pro")
		//        QueryView()
		//            .previewDevice(PreviewDevice(rawValue: "My Mac (Mac Catalyst)"))
		//            .previewDisplayName("Mac Catalyst")
}
