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
	
	@State var elementInspector: Bool = false
	@State private var globalStore = GlobalStore()
	
	let modelContainer: ModelContainer = {
		do {
			let schema = Schema([
				Project.self
			])
			let modelConfiguration = ModelConfiguration(
				schema: schema, 
				isStoredInMemoryOnly: false,
				allowsSave: true,
				cloudKitDatabase: .none
			)
			return try ModelContainer(for: schema, configurations: [modelConfiguration])
		} catch {
			fatalError("Could not create ModelContainer: \(error)")
		}
	}()
    
    var body: some Scene {
        WindowGroup(id: "project-picker") {
			StartingView()
				.environment(globalStore)
				.containerBackground(
					.thinMaterial, for: .window
				)
        }
		.modelContainer(modelContainer)
		.windowStyle(.hiddenTitleBar)
		.defaultPosition(.center)
		.defaultSize(width: 900, height: 500)
		.windowResizability(.contentSize)
		
		WindowGroup("Editor", id: "editor") {
			EditorView()
				.environment(globalStore)
				.inspector(isPresented: .init(
					get: { globalStore.inspectorVisible },
					set: { globalStore.inspectorVisible = $0 }
				)) {
					InspectorView()
						.environment(globalStore)
						.modelContainer(modelContainer)
						.inspectorColumnWidth(min: 260, ideal: 320, max: 500)
				}
				.toolbar {
					ToolbarItem(placement: .automatic) {
						Button {
							globalStore.inspectorVisible.toggle()
						} label: {
							Label("Toggle Inspector", systemImage: "sidebar.right")
						}
					}
				}
		}
		.modelContainer(modelContainer)
		.defaultSize(width: 1400, height: 900)
    }
}
