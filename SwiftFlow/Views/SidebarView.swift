//
//  SidebarView.swift
//  SwiftFlow
//
//  Created by Kevin Perez on 5/9/25.
//

import SwiftUI
import SwiftData

struct SidebarView: View {
	@Environment(GlobalStore.self) private var globalStore
	@Environment(\.modelContext) private var modelContext
	@State private var showingCreateMenu = false
	
	var body: some View {
		@Bindable var store = globalStore
		
		VStack(spacing: 0) {
			// Tab selector
			Picker("", selection: $store.sidebarSelection) {
				ForEach(GlobalStore.SidebarTab.allCases, id: \.self) { tab in
					Image(systemName: tab.icon)
						.tag(tab)
				}
			}
			.pickerStyle(.segmented)
			.frame(maxWidth: .infinity, alignment: .center)
			
			// Content based on selected tab
			Group {
				switch store.sidebarSelection {
				case .files:
					FileNavigatorView()
				case .structure:
					FileStructureView()
				}
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			
			Divider()
			
			// Bottom toolbar
			HStack {
				Button {
					showingCreateMenu = true
				} label: {
					Image(systemName: "plus")
				}
				.popover(isPresented: $showingCreateMenu) {
					CreateFileMenu()
						.frame(width: 200)
				}
				
				Spacer()
			}
			.padding(8)
			.background(Color(NSColor.controlBackgroundColor))
		}
		.frame(minWidth: 240)
	}
}

struct FileNavigatorView: View {
	@Environment(GlobalStore.self) private var globalStore
	@Environment(\.modelContext) private var modelContext
	@Query(sort: \ViewFile.name) private var viewFiles: [ViewFile]
	@Query(sort: \ModelFile.name) private var modelFiles: [ModelFile]
	
	var body: some View {
		List {
			if let project = globalStore.selectedProject {
				// Views Section
				DisclosureGroup {
					ForEach(project.viewFiles.sorted(by: { $0.name < $1.name })) { file in
						FileNavigatorRow(viewFile: file)
					}
					.onDelete { offsets in
						deleteViewFiles(at: offsets, from: project)
					}
				} label: {
					Label("Views", systemImage: "doc.text")
						.font(.caption)
						.foregroundStyle(.secondary)
				}
				
				// Models Section
				DisclosureGroup {
					ForEach(project.modelFiles.sorted(by: { $0.name < $1.name })) { file in
						FileNavigatorRow(modelFile: file)
					}
					.onDelete { offsets in
						deleteModelFiles(at: offsets, from: project)
					}
				} label: {
					Label("Models", systemImage: "cylinder.split.1x2")
						.font(.caption)
						.foregroundStyle(.secondary)
				}
			} else {
				Text("No project selected")
					.font(.caption)
					.foregroundStyle(.secondary)
			}
		}
		.listStyle(.sidebar)
	}
	
	private func deleteViewFiles(at offsets: IndexSet, from project: Project) {
		for index in offsets {
			let file = project.viewFiles.sorted(by: { $0.name < $1.name })[index]
			if globalStore.selectedViewFile == file {
				globalStore.selectedViewFile = nil
			}
			modelContext.delete(file)
			if let idx = project.viewFiles.firstIndex(where: { $0.id == file.id }) {
				project.viewFiles.remove(at: idx)
			}
		}
		try? modelContext.save()
	}
	
	private func deleteModelFiles(at offsets: IndexSet, from project: Project) {
		for index in offsets {
			let file = project.modelFiles.sorted(by: { $0.name < $1.name })[index]
			if globalStore.selectedModelFile == file {
				globalStore.selectedModelFile = nil
			}
			modelContext.delete(file)
			if let idx = project.modelFiles.firstIndex(where: { $0.id == file.id }) {
				project.modelFiles.remove(at: idx)
			}
		}
		try? modelContext.save()
	}
}

struct FileNavigatorRow: View {
	@Environment(GlobalStore.self) private var globalStore
	var viewFile: ViewFile? = nil
	var modelFile: ModelFile? = nil
	
	private var isSelected: Bool {
		if let viewFile = viewFile {
			return globalStore.selectedViewFile == viewFile
		} else if let modelFile = modelFile {
			return globalStore.selectedModelFile == modelFile
		}
		return false
	}
	
	private var icon: String {
		if viewFile != nil {
			return "swift"
		} else {
			return "cylinder"
		}
	}
	
	private var iconColor: Color {
		if viewFile != nil {
			return .orange
		} else {
			return .green
		}
	}
	
	private var fileName: String {
		if let viewFile = viewFile {
			return viewFile.name
		} else if let modelFile = modelFile {
			return modelFile.name
		}
		return ""
	}
	
	var body: some View {
		HStack(spacing: 6) {
			Image(systemName: icon)
				.font(.caption)
				.foregroundStyle(iconColor)
			
			Text(fileName)
				.font(.system(.body, design: .default))
				.lineLimit(1)
			
			Spacer()
		}
		.padding(.vertical, 2)
		.padding(.horizontal, 4)
		.background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
		.cornerRadius(4)
		.contentShape(Rectangle())
		.onTapGesture {
			if let viewFile = viewFile {
				globalStore.selectedViewFile = viewFile
				globalStore.selectedModelFile = nil
			} else if let modelFile = modelFile {
				globalStore.selectedModelFile = modelFile
				globalStore.selectedViewFile = nil
			}
		}
	}
}

struct FileStructureView: View {
	@Environment(GlobalStore.self) private var globalStore
	
	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 0) {
				if let viewFile = globalStore.selectedViewFile {
					ViewFileStructure(viewFile: viewFile)
				} else if let modelFile = globalStore.selectedModelFile {
					ModelFileStructure(modelFile: modelFile)
				} else {
					VStack {
						Image(systemName: "doc.text.magnifyingglass")
							.font(.largeTitle)
							.foregroundStyle(.tertiary)
						Text("No file selected")
							.font(.caption)
							.foregroundStyle(.secondary)
					}
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.padding()
				}
			}
			.padding()
		}
	}
}

struct ViewFileStructure: View {
	let viewFile: ViewFile
	@Environment(GlobalStore.self) private var globalStore
	
	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			// File name header
			HStack {
				Image(systemName: "swift")
					.foregroundStyle(.orange)
				Text(viewFile.name)
					.font(.headline)
			}
			
			Divider()
			
			// Variables section
			if !viewFile.variables.isEmpty {
				DisclosureGroup {
					ForEach(viewFile.variables) { variable in
						VariableStructureRow(variable: variable)
					}
				} label: {
					Label("Variables (\(viewFile.variables.count))", systemImage: "function")
						.font(.caption)
						.foregroundStyle(.secondary)
				}
			}
			
			// Components section
			if !viewFile.components.isEmpty {
				DisclosureGroup {
					ForEach(viewFile.components) { component in
						ComponentStructureRow(component: component, level: 0)
					}
				} label: {
					Label("Components (\(viewFile.components.count))", systemImage: "square.stack.3d.up")
						.font(.caption)
						.foregroundStyle(.secondary)
				}
			}
		}
	}
}

struct ModelFileStructure: View {
	let modelFile: ModelFile
	
	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			// File name header
			HStack {
				Image(systemName: "cylinder")
					.foregroundStyle(.green)
				Text(modelFile.name)
					.font(.headline)
			}
			
			Divider()
			
			// Fields section
			if !modelFile.fields.isEmpty {
				DisclosureGroup {
					ForEach(modelFile.fields) { field in
						FieldStructureRow(field: field)
					}
				} label: {
					Label("Fields (\(modelFile.fields.count))", systemImage: "list.bullet")
						.font(.caption)
						.foregroundStyle(.secondary)
				}
			}
		}
	}
}

struct VariableStructureRow: View {
	let variable: Variable
	
	var body: some View {
		HStack {
			Image(systemName: "chevron.right")
				.font(.caption2)
				.foregroundStyle(.tertiary)
			
			Text(kindPrefix)
				.font(.caption)
				.foregroundStyle(.purple)
			
			Text(variable.name)
				.font(.caption)
			
			Text(":")
				.foregroundStyle(.secondary)
			
			Text(variable.type)
				.font(.caption)
				.foregroundStyle(.blue)
			
			Spacer()
		}
		.padding(.leading, 8)
	}
	
	private var kindPrefix: String {
		switch variable.kind {
		case .state: return "@State"
		case .binding: return "@Binding"
		case .constant: return "let"
		case .environment: return "@Environment"
		case .observedObject: return "@ObservedObject"
		case .environmentObject: return "@EnvironmentObject"
		}
	}
}

struct ComponentStructureRow: View {
	let component: Component
	let level: Int
	@Environment(GlobalStore.self) private var globalStore
	@State private var isExpanded = true
	
	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			HStack {
				if !component.children.isEmpty {
					Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
						.font(.caption2)
						.foregroundStyle(.tertiary)
						.onTapGesture {
							isExpanded.toggle()
						}
				} else {
					Image(systemName: "chevron.right")
						.font(.caption2)
						.foregroundStyle(.tertiary)
						.opacity(0.3)
				}
				
				Image(systemName: componentIcon)
					.font(.caption)
					.foregroundStyle(.blue)
				
				Text(componentName)
					.font(.caption)
				
				Spacer()
				
				if globalStore.selectedComponent == component {
					Image(systemName: "checkmark.circle.fill")
						.font(.caption)
						.foregroundStyle(.green)
				}
			}
			.padding(.leading, CGFloat(level * 16))
			.contentShape(Rectangle())
			.onTapGesture {
				globalStore.selectedComponent = component
			}
			
			if isExpanded && !component.children.isEmpty {
				ForEach(component.children) { child in
					ComponentStructureRow(component: child, level: level + 1)
				}
			}
		}
	}
	
	private var componentName: String {
		switch component.type {
		case .text: return "Text"
		case .image: return "Image"
		case .vstack: return "VStack"
		case .hstack: return "HStack"
		case .zstack: return "ZStack"
		case .spacer: return "Spacer"
		case .button: return "Button"
		case .textField: return "TextField"
		case .customView: return "Custom View"
		}
	}
	
	private var componentIcon: String {
		switch component.type {
		case .text: return "textformat"
		case .image: return "photo"
		case .vstack: return "rectangle.split.3x1"
		case .hstack: return "rectangle.split.1x2"
		case .zstack: return "square.stack.3d.up"
		case .spacer: return "arrow.left.and.right"
		case .button: return "button.programmable"
		case .textField: return "character.textbox"
		case .customView: return "doc.badge.plus"
		}
	}
}

struct FieldStructureRow: View {
	let field: ModelField
	
	var body: some View {
		HStack {
			Image(systemName: "chevron.right")
				.font(.caption2)
				.foregroundStyle(.tertiary)
			
			Text(field.name)
				.font(.caption)
			
			Text(":")
				.foregroundStyle(.secondary)
			
			Text(field.type)
				.font(.caption)
				.foregroundStyle(.purple)
			
			if let defaultValue = field.defaultValue {
				Text("= \(defaultValue)")
					.font(.caption)
					.foregroundStyle(.secondary)
			}
			
			Spacer()
		}
		.padding(.leading, 8)
	}
}

struct CreateFileMenu: View {
	@Environment(\.dismiss) private var dismiss
	@Environment(GlobalStore.self) private var globalStore
	@Environment(\.modelContext) private var modelContext
	@State private var fileType: FileType = .view
	@State private var fileName = ""
	
	enum FileType: String, CaseIterable {
		case view = "View"
		case model = "Model"
		
		var icon: String {
			switch self {
			case .view: return "swift"
			case .model: return "cylinder"
			}
		}
	}
	
	var body: some View {
		VStack(spacing: 16) {
			Text("New File")
				.font(.headline)
			
			Picker("Type", selection: $fileType) {
				ForEach(FileType.allCases, id: \.self) { type in
					Label(type.rawValue, systemImage: type.icon)
						.tag(type)
				}
			}
			.pickerStyle(.segmented)
			
			TextField("File Name", text: $fileName)
				.textFieldStyle(.roundedBorder)
			
			HStack {
				Button("Cancel") {
					dismiss()
				}
				
				Spacer()
				
				Button("Create") {
					createFile()
				}
				.buttonStyle(.borderedProminent)
				.disabled(fileName.isEmpty)
			}
		}
		.padding()
	}
	
	private func createFile() {
		guard let project = globalStore.selectedProject,
			  !fileName.isEmpty else { return }
		
		switch fileType {
		case .view:
			let newFile = ViewFile(name: fileName)
			project.viewFiles.append(newFile)
			globalStore.selectedViewFile = newFile
			globalStore.selectedModelFile = nil
		case .model:
			let newFile = ModelFile(name: fileName)
			project.modelFiles.append(newFile)
			globalStore.selectedModelFile = newFile
			globalStore.selectedViewFile = nil
		}
		
		try? modelContext.save()
		dismiss()
	}
}

#Preview {
	SidebarView()
		.environment(GlobalStore())
}
