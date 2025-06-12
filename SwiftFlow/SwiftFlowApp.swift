//
//  SwiftFlowApp.swift
//  SwiftFlow
//
//  Created by Kevin Perez on 4/24/25.
//

import SwiftUI
import SwiftData

@main
struct SwiftFlowApp: App {
	
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismissWindow) private var dismissWindow
	@State var elementInspector: Bool = false
	@State private var globalStore = GlobalStore()
    
    var body: some Scene {
        WindowGroup(id: "project-picker") {
			StartingView()
				.environment(globalStore)
				.onAppear {
					// This will ensure the view model has access to model context
					let modelContainer = try? ModelContainer(for: Project.self)
				}
        }
		.windowStyle(.hiddenTitleBar)
		.defaultPosition(.center)
		.defaultSize(width: 500, height: 300)
		
		Window("Editor", id: "editor") {
			EditorView()
				.environment(globalStore)
				.toolbar {
					ToolbarItem {
						Button {
							print("Toggle Inspector Panel")
						} label: {
							Label("Inspector", systemImage: "sidebar.right")
						}
					}
				}
				.inspector(isPresented: $elementInspector) {
					Text("Inspector panel")
				}
				.onAppear {
					// This will ensure the view model has access to model context
					let modelContainer = try? ModelContainer(for: Project.self)
				}
		}
    }
}
