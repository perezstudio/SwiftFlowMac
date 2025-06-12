//
//  CreateProjectView.swift
//  SwiftFlow
//
//  Created by Kevin Perez on 5/8/25.
//

import SwiftUI
import SwiftData

struct CreateProjectView: View {
	
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	@Environment(\.dismissWindow) private var dismissWindow
	@Environment(\.openWindow) private var openWindow
	@Environment(GlobalStore.self) private var globalStore
	@State var projectName: String = "My Next App"
	@State var projectIcon: String = "square.and.arrow.up"
	@State var projectColor: ProjectColor = .blue
	
	var body: some View {
		Form {
			Group {
				TextField("Project Name", text: $projectName)
			}
			Group {
				ScrollView(.horizontal, showsIndicators: false) {
					HStack(spacing: 32) {
						ForEach(iconCategories) { category in
							IconCategoryColumnView(selectedIcon: $projectIcon, category: category)
						}
					}
					.padding(.vertical)
				}
			}
			Group {
				ColorPickerGridView(selectedColor: $projectColor)
			}
		}
		.padding()
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Button {
					createProject()
					dismiss()
				} label: {
					Label("Create Project", systemImage: "plus")
				}
			}
			ToolbarItem(placement: .cancellationAction) {
				Button {
					dismiss()
				} label: {
					Label("Cancel", systemImage: "xmark")
				}
			}
		}
	}
	
	private func createProject() {
		let newProject = Project(name: projectName, icon: projectIcon, color: projectColor)
		modelContext.insert(newProject)
		openWindow(id: "editor")
		globalStore.selectedProject = newProject
		dismiss()
	}
	
}

#Preview {
	CreateProjectView()
}
