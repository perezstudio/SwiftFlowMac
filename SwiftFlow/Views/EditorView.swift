//
//  EditorView.swift
//  SwiftFlow
//
//  Created by Kevin Perez on 5/7/25.
//

import SwiftUI
import SwiftData

struct EditorView: View {
	
	@Environment(GlobalStore.self) var globalStore
	@Environment(\.modelContext) private var modelContext
	@State private var columnVisibility: NavigationSplitViewVisibility = .all
	
	var body: some View {
		@Bindable var store = globalStore
		
		NavigationSplitView {
			SidebarView()
				.navigationSplitViewColumnWidth(min: 240, ideal: 280, max: 400)
		} detail: {
			if globalStore.selectedViewFile != nil || globalStore.selectedModelFile != nil {
				CanvasView()
			} else {
				VStack(spacing: 20) {
					Image(systemName: "doc.text")
						.font(.system(size: 60))
						.foregroundStyle(.secondary)
					Text("Select a File")
						.font(.title2)
						.foregroundStyle(.primary)
					Text("Select a view or model file to start editing")
						.font(.body)
						.foregroundStyle(.secondary)
				}
			}
		}
		.navigationTitle(globalStore.selectedProject?.name ?? "SwiftFlow")
		.toolbar {
			ToolbarItem(placement: .navigation) {
				Button {
					globalStore.isShowingComponentPalette.toggle()
				} label: {
					Label("Components", systemImage: "plus.square.dashed")
				}
				.popover(isPresented: .init(
					get: { globalStore.isShowingComponentPalette },
					set: { globalStore.isShowingComponentPalette = $0 }
				)) {
					ComponentPaletteView()
						.frame(width: 320, height: 450)
				}
				.help("Add Component")
			}
		}
	}
}

