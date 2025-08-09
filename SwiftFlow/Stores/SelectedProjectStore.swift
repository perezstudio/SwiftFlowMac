//
//  GlobalStore.swift
//  SwiftFlow
//
//  Created by Kevin Perez on 5/8/25.
//

import SwiftUI
import SwiftData
import Observation

@Observable class GlobalStore {
	var selectedProject: Project? = nil
	var selectedViewFile: ViewFile? = nil
	var selectedModelFile: ModelFile? = nil
	var selectedComponent: Component? = nil
	var isShowingComponentPalette: Bool = false
	var draggedComponent: Component? = nil
	var sidebarSelection: SidebarTab = .files
	var inspectorVisible: Bool = true
	
	enum SidebarTab: String, CaseIterable {
		case files = "Files"
		case structure = "Structure"
		
		var icon: String {
			switch self {
			case .files: return "folder"
			case .structure: return "list.bullet.indent"
			}
		}
	}
}
