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
	
	var body: some View {
		NavigationSplitView {
			SidebarView()
		} detail: {
			if let selectedProject = globalStore.selectedProject {
				Text("Editor View")
				Text(selectedProject.name)
			}
		}
	}
}

