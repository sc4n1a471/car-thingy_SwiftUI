//
    //  QueryView.swift
    //  NodeJS_Thingy_Cars
    //
    //  Created by Martin Terhes on 5/21/23.
    //

import SwiftUI

struct QueryView: View {
    @FocusState private var lpTextFieldFocused: Bool
    
    @State private var viewModel = ViewModel()
    @State var websocket: Websocket = Websocket()
    @State private var requestedLicensePlate: String = String()
	@State private var showVersionPopover: Bool = false
	
	@State private var verificationCode: String = String()
	
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
				
				if websocket.isLoading {
					openQuerySheet
				} else {
					Button {
						Task {
							lpTextFieldFocused = false
							await websocket.connect(requestedLicensePlate)
						}
					} label: {
						Text("Request")
							.frame(maxWidth: 200, maxHeight: 50)
					}
					.buttonStyle(.borderless)
					.foregroundColor(.white)
					.background(!websocket.isLoading ? Color.blue : Color.gray)
					.cornerRadius(10)
				}
                
                Button {
                    Task {
                        await websocket.connect("test111")
                    }
                } label: {
                    Text("Test Request")
                        .frame(maxWidth: 200, maxHeight: 50)
                }
                .buttonStyle(.borderless)
                .foregroundColor(.white)
                .background(!websocket.isLoading ? Color.blue : Color.gray)
                .cornerRadius(10)
                .disabled(websocket.isLoading)
            }
            .padding()
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing, content: {
                    Button(action: {
                        websocket.openSheet()
                    }) {
                        Image(systemName: "tray")
                    }
                    .isHidden(!websocket.isSuccess)
                })
				
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
							
							Text(env == "prod" ? "Production" : "Development")
								.frame(maxWidth: .infinity, alignment: .leading)
								.padding()
						}
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.presentationCompactAdaptation(.none)
						.presentationBackground(.clear)
					}
				})
            }
            .navigationTitle("Car Query")
			.navigationBarTitleDisplayMode(.large)
        }
        .alert(websocket.error, isPresented: $websocket.isAlert, actions: {
            Button("Websocket got it") {
                websocket.disableAlert()
                print("websocket alert confirmed")
            }
        })
		.alert("2FA", isPresented: $websocket.verificationDialogOpen) {
			SecureField(text: $verificationCode) {}
			
			Button("Cancel") {
				websocket.close()
			}
			
			Button("Submit") {
				websocket.dismissCodeDialog(verificationCode: verificationCode)
			}
		} message: {
			Text("Pls gimme 2fa code")
		}
        .sheet(isPresented: $websocket.dataSheetOpened, onDismiss: {
            Task {
                await websocket.dismissSheet()
            }
        }) {
            QuerySheetView(websocket: websocket, knownCarQuery: false)
                .presentationDetents([.medium, .large])
        }
    }
	
	var openQuerySheet: some View {
		Button(action: {
			websocket.openSheet()
		}) {
			Gauge(value: websocket.percentage, in: 0...100) {}
				.gaugeStyle(.accessoryCircularCapacity)
				.tint(.blue)
				.scaleEffect(0.5)
//				.frame(width: 25, height: 25)
//				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.frame(maxWidth: 175, maxHeight: 37)
		}
		.buttonStyle(.bordered)
		.tint(.blue)
	}
}

#Preview {
	QueryView()
		.previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
		.previewDisplayName("iPhone 13 Pro")
		//        QueryView()
		//            .previewDevice(PreviewDevice(rawValue: "My Mac (Mac Catalyst)"))
		//            .previewDisplayName("Mac Catalyst")
}
