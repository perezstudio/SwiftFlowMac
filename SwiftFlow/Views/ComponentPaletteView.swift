//
//  ComponentPaletteView.swift
//  SwiftFlow
//
//  Created by Kevin Perez on 5/9/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ComponentPaletteView: View {
	@Environment(GlobalStore.self) private var globalStore
	@Environment(\.dismiss) private var dismiss
	
	let componentCategories: [(String, [ComponentType])] = [
		("Layout", [.vstack, .hstack, .zstack, .spacer]),
		("Controls", [.button, .textField]),
		("Display", [.text, .image]),
		("Custom", [.customView])
	]
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(alignment: .leading, spacing: 20) {
					ForEach(componentCategories, id: \.0) { category, components in
						VStack(alignment: .leading, spacing: 12) {
							Text(category)
								.font(.headline)
								.foregroundStyle(.secondary)
							
							LazyVGrid(columns: [
								GridItem(.adaptive(minimum: 80))
							], spacing: 12) {
								ForEach(components, id: \.self) { componentType in
									ComponentTileView(componentType: componentType)
								}
							}
						}
						.padding(.horizontal)
					}
				}
				.padding(.vertical)
			}
			.navigationTitle("Components")
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button("Done") {
						dismiss()
					}
				}
			}
		}
	}
}

struct ComponentTileView: View {
	let componentType: ComponentType
	@Environment(GlobalStore.self) private var globalStore
	
	var componentIcon: String {
		switch componentType {
		case .text: return "textformat"
		case .image: return "photo"
		case .vstack: return "rectangle.split.1x3"
		case .hstack: return "rectangle.split.3x1"
		case .zstack: return "square.stack.3d.up"
		case .spacer: return "arrow.left.and.right"
		case .button: return "button.programmable"
		case .textField: return "character.textbox"
		case .customView: return "doc.badge.plus"
		}
	}
	
	var componentName: String {
		switch componentType {
		case .text: return "Text"
		case .image: return "Image"
		case .vstack: return "VStack"
		case .hstack: return "HStack"
		case .zstack: return "ZStack"
		case .spacer: return "Spacer"
		case .button: return "Button"
		case .textField: return "TextField"
		case .customView: return "Custom"
		}
	}
	
	var body: some View {
		VStack(spacing: 8) {
			Image(systemName: componentIcon)
				.font(.title2)
				.frame(width: 40, height: 40)
			
			Text(componentName)
				.font(.caption)
				.lineLimit(1)
		}
		.frame(width: 80, height: 80)
		.background(Color.gray.opacity(0.1))
		.cornerRadius(8)
		.draggable(ComponentTransferable(type: componentType)) {
			VStack(spacing: 4) {
				Image(systemName: componentIcon)
					.font(.title3)
				Text(componentName)
					.font(.caption2)
			}
			.padding(8)
			.background(Color.accentColor.opacity(0.2))
			.cornerRadius(6)
		}
	}
}

struct ComponentTransferable: Transferable, Codable {
	let type: ComponentType
	let id: UUID
	
	init(type: ComponentType) {
		self.type = type
		self.id = UUID()
	}
	
	static var transferRepresentation: some TransferRepresentation {
		CodableRepresentation(contentType: .component)
	}
}

struct ExistingComponentTransferable: Transferable, Codable {
	let componentId: UUID
	
	init(component: Component) {
		self.componentId = component.id
	}
	
	static var transferRepresentation: some TransferRepresentation {
		CodableRepresentation(contentType: .existingComponent)
	}
}

extension UTType {
	static var component: UTType {
		UTType(exportedAs: "com.swiftflow.component")
	}
	
	static var existingComponent: UTType {
		UTType(exportedAs: "com.swiftflow.existingcomponent")
	}
}

#Preview {
	ComponentPaletteView()
		.environment(GlobalStore())
		.frame(width: 300, height: 400)
}