//
//  InspectorView.swift
//  SwiftFlow
//
//  Created by Kevin Perez on 5/9/25.
//

import SwiftUI
import SwiftData

struct InspectorView: View {
	@Environment(GlobalStore.self) private var globalStore
	@Environment(\.modelContext) private var modelContext
	
	var body: some View {
		ScrollView {
			if let component = globalStore.selectedComponent {
				ComponentInspector(component: component)
			} else if let viewFile = globalStore.selectedViewFile {
				ViewFileInspector(viewFile: viewFile)
			} else if let modelFile = globalStore.selectedModelFile {
				ModelFileInspector(modelFile: modelFile)
			} else {
				VStack(spacing: 20) {
					Image(systemName: "sidebar.right")
						.font(.system(size: 48))
						.foregroundStyle(.tertiary)
					
					Text("No Selection")
						.font(.headline)
						.foregroundStyle(.secondary)
					
					Text("Select a component or file to view its properties")
						.font(.body)
						.foregroundStyle(.tertiary)
						.multilineTextAlignment(.center)
				}
				.padding(.top, 60)
			}
		}
	}
}

struct ComponentInspector: View {
	let component: Component
	@Environment(\.modelContext) private var modelContext
	@State private var showingAddProperty = false
	@State private var showingAddModifier = false
	@State private var propertyKey = ""
	@State private var propertyValue = ""
	@State private var modifierName = ""
	
	var componentTitle: String {
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
	
	var componentIcon: String {
		switch component.type {
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
	
	var body: some View {
		VStack(spacing: 16) {
			// Header with selected element info
			HStack {
				Image(systemName: componentIcon)
					.font(.title)
					.foregroundColor(.blue)
				
				Text(componentTitle)
					.font(.title2)
					.fontWeight(.bold)
					.foregroundColor(.primary)
				
				Spacer()
			}
			.padding(.horizontal, 16)
			.padding(.vertical, 12)
			.background(
				RoundedRectangle(cornerRadius: 12)
					.fill(.regularMaterial)
			)
			.padding(.horizontal, 16)
			
			// Properties Section Header
			HStack {
				Image(systemName: "slider.horizontal.3")
					.font(.body)
					.foregroundColor(.blue)
				
				Text("Properties")
					.font(.headline)
					.fontWeight(.semibold)
					.foregroundColor(.primary)
				
				Spacer()
				
				Button {
					showingAddProperty = true
				} label: {
					Image(systemName: "plus.circle")
						.foregroundColor(.blue)
				}
				.buttonStyle(.plain)
			}
			.padding(.horizontal, 16)
			
			// Properties Items
			if component.properties.isEmpty {
				Text("No properties")
					.foregroundStyle(.secondary)
					.padding(.horizontal, 16)
			} else {
				VStack(spacing: 8) {
					ForEach(component.properties) { property in
						PropertyRow(property: property, component: component)
							.padding(.horizontal, 16)
							.padding(.vertical, 12)
							.background(
								RoundedRectangle(cornerRadius: 12)
									.fill(.regularMaterial)
							)
					}
				}
				.padding(.horizontal, 16)
			}
			
			// Modifiers Section Header
			HStack {
				Image(systemName: "paintbrush")
					.font(.body)
					.foregroundColor(.blue)
				
				Text("Modifiers")
					.font(.headline)
					.fontWeight(.semibold)
					.foregroundColor(.primary)
				
				Spacer()
				
				Button {
					showingAddModifier = true
				} label: {
					Image(systemName: "plus.circle")
						.foregroundColor(.blue)
				}
				.buttonStyle(.plain)
			}
			.padding(.horizontal, 16)
			
			// Modifiers Items
			if component.modifiers.isEmpty {
				Text("No modifiers")
					.foregroundStyle(.secondary)
					.padding(.horizontal, 16)
			} else {
				VStack(spacing: 8) {
					ForEach(component.modifiers) { modifier in
						ModifierRow(modifier: modifier, component: component)
							.padding(.horizontal, 16)
							.padding(.vertical, 12)
							.background(
								RoundedRectangle(cornerRadius: 12)
									.fill(.regularMaterial)
							)
					}
				}
				.padding(.horizontal, 16)
			}
			
			// Children Section (for containers)
			if component.type == .vstack || component.type == .hstack || component.type == .zstack {
				// Children Section Header
				HStack {
					Image(systemName: "square.stack.3d.down.right")
						.font(.body)
						.foregroundColor(.blue)
					
					Text("Children")
						.font(.headline)
						.fontWeight(.semibold)
						.foregroundColor(.primary)
					
					Spacer()
				}
				.padding(.horizontal, 16)
				
				// Children Items
				if component.children.isEmpty {
					Text("Drop components here")
						.foregroundStyle(.secondary)
						.padding(.horizontal, 16)
				} else {
					VStack(spacing: 8) {
						ForEach(component.children) { child in
							ChildRow(child: child)
								.padding(.horizontal, 16)
								.padding(.vertical, 12)
								.background(
									RoundedRectangle(cornerRadius: 12)
										.fill(.regularMaterial)
								)
						}
					}
					.padding(.horizontal, 16)
				}
			}
			
			Spacer(minLength: 20)
		}
		.padding(.top, 16)
		.sheet(isPresented: $showingAddProperty) {
			AddPropertySheet(
				propertyKey: $propertyKey,
				propertyValue: $propertyValue
			) {
				let property = ComponentProperty(key: propertyKey, value: propertyValue)
				component.properties.append(property)
				try? modelContext.save()
				
				propertyKey = ""
				propertyValue = ""
				showingAddProperty = false
			}
		}
		.sheet(isPresented: $showingAddModifier) {
			AddModifierSheet(
				modifierName: $modifierName,
				availableModifiers: [
					"padding", "frame", "background", "foregroundColor",
					"font", "cornerRadius", "shadow", "opacity",
					"scaleEffect", "rotationEffect", "offset", "clipShape"
				]
			) { name, arguments in
				let modifier = Modifier(name: name)
				modifier.arguments = arguments
				component.modifiers.append(modifier)
				try? modelContext.save()
				
				modifierName = ""
				showingAddModifier = false
			}
		}
	}
}


struct PropertyRow: View {
	let property: ComponentProperty
	let component: Component
	@Environment(\.modelContext) private var modelContext
	@State private var editedValue: String = ""
	@State private var isEditing = false
	
	var body: some View {
		HStack {
			Text(property.key)
				.frame(width: 80, alignment: .leading)
			
			if isEditing {
				TextField("Value", text: $editedValue)
					.onSubmit {
						property.value = editedValue
						try? modelContext.save()
						isEditing = false
					}
			} else {
				Text(property.value)
					.frame(maxWidth: .infinity, alignment: .leading)
					.contentShape(Rectangle())
					.onTapGesture {
						editedValue = property.value
						isEditing = true
					}
			}
			
			Button {
				if let index = component.properties.firstIndex(where: { $0.id == property.id }) {
					component.properties.remove(at: index)
					modelContext.delete(property)
					try? modelContext.save()
				}
			} label: {
				Image(systemName: "trash")
			}
			.buttonStyle(.plain)
		}
	}
}


struct ModifierRow: View {
	let modifier: Modifier
	let component: Component
	@Environment(\.modelContext) private var modelContext
	
	var body: some View {
		HStack {
			Text(".\(modifier.name)")
			
			if !modifier.arguments.isEmpty {
				Text("(")
					.foregroundStyle(.secondary)
				
				ForEach(Array(modifier.arguments.enumerated()), id: \.offset) { index, arg in
					if let name = arg.name {
						Text("\(name):")
							.foregroundStyle(.secondary)
					}
					Text(arg.value)
					
					if index < modifier.arguments.count - 1 {
						Text(",")
							.foregroundStyle(.secondary)
					}
				}
				
				Text(")")
					.foregroundStyle(.secondary)
			}
			
			Spacer()
			
			Button {
				if let index = component.modifiers.firstIndex(where: { $0.id == modifier.id }) {
					component.modifiers.remove(at: index)
					modelContext.delete(modifier)
					try? modelContext.save()
				}
			} label: {
				Image(systemName: "trash")
			}
			.buttonStyle(.plain)
		}
	}
}


struct ChildRow: View {
	let child: Component
	@Environment(GlobalStore.self) private var globalStore
	
	var childIcon: String {
		switch child.type {
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
	
	var body: some View {
		HStack {
			Image(systemName: childIcon)
			
			Text(String(describing: child.type).capitalized)
			
			Spacer()
			
			if globalStore.selectedComponent == child {
				Image(systemName: "checkmark.circle.fill")
			}
		}
		.contentShape(Rectangle())
		.onTapGesture {
			globalStore.selectedComponent = child
		}
	}
}

struct ViewFileInspector: View {
	let viewFile: ViewFile
	@Environment(\.modelContext) private var modelContext
	@State private var showingAddVariable = false
	@State private var variableName = ""
	@State private var variableType = "String"
	@State private var variableKind: VariableKind = .state
	
	var body: some View {
		VStack(spacing: 16) {
			// Header with selected file info
			HStack {
				Image(systemName: "doc.text")
					.font(.title)
					.foregroundColor(.blue)
				
				Text(viewFile.name)
					.font(.title2)
					.fontWeight(.bold)
					.foregroundColor(.primary)
				
				Spacer()
			}
			.padding(.horizontal, 16)
			.padding(.vertical, 12)
			.background(
				RoundedRectangle(cornerRadius: 12)
					.fill(.regularMaterial)
			)
			.padding(.horizontal, 16)
			
			// File Info Section Header
			HStack {
				Image(systemName: "doc.text.fill")
					.font(.body)
					.foregroundColor(.blue)
				
				Text("File Info")
					.font(.headline)
					.fontWeight(.semibold)
					.foregroundColor(.primary)
				
				Spacer()
			}
			.padding(.horizontal, 16)
			
			// File Info Item
			Text("\(viewFile.components.count) components")
				.foregroundStyle(.secondary)
				.padding(.horizontal, 16)
				.padding(.vertical, 12)
				.frame(maxWidth: .infinity, alignment: .leading)
				.background(
					RoundedRectangle(cornerRadius: 12)
						.fill(.regularMaterial)
				)
				.padding(.horizontal, 16)
			
			// Variables Section Header
			HStack {
				Image(systemName: "function")
					.font(.body)
					.foregroundColor(.blue)
				
				Text("Variables")
					.font(.headline)
					.fontWeight(.semibold)
					.foregroundColor(.primary)
				
				Spacer()
				
				Button {
					showingAddVariable = true
				} label: {
					Image(systemName: "plus.circle")
						.foregroundColor(.blue)
				}
				.buttonStyle(.plain)
			}
			.padding(.horizontal, 16)
			
			// Variables Items
			if viewFile.variables.isEmpty {
				Text("No variables")
					.foregroundStyle(.secondary)
					.padding(.horizontal, 16)
			} else {
				VStack(spacing: 8) {
					ForEach(viewFile.variables) { variable in
						VariableRow(variable: variable, viewFile: viewFile)
							.padding(.horizontal, 16)
							.padding(.vertical, 12)
							.background(
								RoundedRectangle(cornerRadius: 12)
									.fill(.regularMaterial)
							)
					}
				}
				.padding(.horizontal, 16)
			}
			
			Spacer(minLength: 20)
		}
		.padding(.top, 16)
		.sheet(isPresented: $showingAddVariable) {
			AddVariableSheet(
				variableName: $variableName,
				variableType: $variableType,
				variableKind: $variableKind
			) {
				let variable = Variable(
					name: variableName,
					type: variableType,
					kind: variableKind
				)
				viewFile.variables.append(variable)
				try? modelContext.save()
				
				variableName = ""
				variableType = "String"
				variableKind = .state
				showingAddVariable = false
			}
		}
	}
}

struct VariableRow: View {
	let variable: Variable
	let viewFile: ViewFile
	@Environment(\.modelContext) private var modelContext
	
	var kindPrefix: String {
		switch variable.kind {
		case .state: return "@State"
		case .binding: return "@Binding"
		case .constant: return "let"
		case .environment: return "@Environment"
		case .observedObject: return "@ObservedObject"
		case .environmentObject: return "@EnvironmentObject"
		}
	}
	
	var kindColor: Color {
		switch variable.kind {
		case .state, .binding, .environment, .observedObject, .environmentObject:
			return .purple
		case .constant:
			return .blue
		}
	}
	
	var body: some View {
		HStack {
			Text(kindPrefix)
				.font(.system(.caption, design: .monospaced))
				.foregroundStyle(kindColor)
				.frame(width: 80, alignment: .leading)
			
			Text(variable.name)
				.font(.system(.body, design: .monospaced))
			
			Text(":")
				.foregroundStyle(.secondary)
			
			Text(variable.type)
				.font(.system(.body, design: .monospaced))
				.foregroundStyle(.green)
			
			Spacer()
			
			Button {
				if let index = viewFile.variables.firstIndex(where: { $0.id == variable.id }) {
					viewFile.variables.remove(at: index)
					modelContext.delete(variable)
					try? modelContext.save()
				}
			} label: {
				Image(systemName: "trash")
					.foregroundStyle(.red)
			}
			.buttonStyle(.plain)
		}
		.padding(.vertical, 2)
	}
}

struct ModelFileInspector: View {
	let modelFile: ModelFile
	
	var body: some View {
		VStack(spacing: 16) {
			// Header with selected model info
			HStack {
				Image(systemName: "cylinder.split.1x2")
					.font(.title)
					.foregroundColor(.blue)
				
				Text(modelFile.name)
					.font(.title2)
					.fontWeight(.bold)
					.foregroundColor(.primary)
				
				Spacer()
			}
			.padding(.horizontal, 16)
			.padding(.vertical, 12)
			.background(
				RoundedRectangle(cornerRadius: 12)
					.fill(.regularMaterial)
			)
			.padding(.horizontal, 16)
			
			// Model Info Section Header
			HStack {
				Image(systemName: "info.circle")
					.font(.body)
					.foregroundColor(.blue)
				
				Text("Model Info")
					.font(.headline)
					.fontWeight(.semibold)
					.foregroundColor(.primary)
				
				Spacer()
			}
			.padding(.horizontal, 16)
			
			// Model Info Items
			VStack(spacing: 8) {
				VStack(alignment: .leading, spacing: 4) {
					Text("\(modelFile.fields.count) fields")
						.foregroundStyle(.secondary)
					Text("SwiftData @Model")
						.foregroundStyle(.secondary)
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding(.horizontal, 16)
				.padding(.vertical, 12)
				.background(
					RoundedRectangle(cornerRadius: 12)
						.fill(.regularMaterial)
				)
			}
			.padding(.horizontal, 16)
			
			Spacer(minLength: 20)
		}
		.padding(.top, 16)
	}
}

struct AddPropertySheet: View {
	@Binding var propertyKey: String
	@Binding var propertyValue: String
	let onAdd: () -> Void
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		NavigationStack {
			Form {
				TextField("Property Name", text: $propertyKey)
				TextField("Value", text: $propertyValue)
			}
			.padding()
			.navigationTitle("Add Property")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") {
						dismiss()
					}
				}
				
				ToolbarItem(placement: .confirmationAction) {
					Button("Add") {
						onAdd()
					}
					.disabled(propertyKey.isEmpty || propertyValue.isEmpty)
				}
			}
		}
		.frame(width: 400, height: 200)
	}
}

struct AddModifierSheet: View {
	@Binding var modifierName: String
	let availableModifiers: [String]
	let onAdd: (String, [ModifierArgument]) -> Void
	@Environment(\.dismiss) private var dismiss
	@State private var arguments: [(name: String?, value: String)] = []
	
	var body: some View {
		NavigationStack {
			Form {
				Picker("Modifier", selection: $modifierName) {
					ForEach(availableModifiers, id: \.self) { modifier in
						Text(modifier).tag(modifier)
					}
				}
				.onChange(of: modifierName) { _, newValue in
					updateArgumentsForModifier(newValue)
				}
				
				if !arguments.isEmpty {
					Section("Arguments") {
						ForEach(arguments.indices, id: \.self) { index in
							HStack {
								if let name = arguments[index].name {
									Text("\(name):")
										.foregroundStyle(.secondary)
								}
								TextField("Value", text: Binding(
									get: { arguments[index].value },
									set: { arguments[index].value = $0 }
								))
							}
						}
					}
				}
			}
			.padding()
			.navigationTitle("Add Modifier")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") {
						dismiss()
					}
				}
				
				ToolbarItem(placement: .confirmationAction) {
					Button("Add") {
						let modifierArguments = arguments.map { arg in
							ModifierArgument(name: arg.name, value: arg.value)
						}
						onAdd(modifierName, modifierArguments)
					}
					.disabled(modifierName.isEmpty)
				}
			}
		}
		.frame(width: 400, height: 300)
		.onAppear {
			if !modifierName.isEmpty {
				updateArgumentsForModifier(modifierName)
			}
		}
	}
	
	private func updateArgumentsForModifier(_ modifier: String) {
		switch modifier {
		case "padding":
			arguments = [(nil, "16")]
		case "frame":
			arguments = [("width", "100"), ("height", "50")]
		case "background":
			arguments = [(nil, ".blue")]
		case "foregroundColor":
			arguments = [(nil, ".primary")]
		case "font":
			arguments = [(nil, ".title")]
		case "cornerRadius":
			arguments = [(nil, "8")]
		case "shadow":
			arguments = [("radius", "5")]
		case "opacity":
			arguments = [(nil, "0.5")]
		case "scaleEffect":
			arguments = [(nil, "1.2")]
		case "rotationEffect":
			arguments = [(nil, "45")]
		case "offset":
			arguments = [("x", "0"), ("y", "0")]
		default:
			arguments = []
		}
	}
}

struct AddVariableSheet: View {
	@Binding var variableName: String
	@Binding var variableType: String
	@Binding var variableKind: VariableKind
	let onAdd: () -> Void
	@Environment(\.dismiss) private var dismiss
	
	let commonTypes = ["String", "Int", "Double", "Bool", "Date", "UUID", "CGFloat"]
	
	var body: some View {
		NavigationStack {
			Form {
				TextField("Variable Name", text: $variableName)
				
				Picker("Type", selection: $variableType) {
					ForEach(commonTypes, id: \.self) { type in
						Text(type).tag(type)
					}
				}
				
				Picker("Kind", selection: $variableKind) {
					Text("@State").tag(VariableKind.state)
					Text("@Binding").tag(VariableKind.binding)
					Text("let").tag(VariableKind.constant)
					Text("@Environment").tag(VariableKind.environment)
					Text("@ObservedObject").tag(VariableKind.observedObject)
					Text("@EnvironmentObject").tag(VariableKind.environmentObject)
				}
			}
			.padding()
			.navigationTitle("Add Variable")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") {
						dismiss()
					}
				}
				
				ToolbarItem(placement: .confirmationAction) {
					Button("Add") {
						onAdd()
					}
					.disabled(variableName.isEmpty)
				}
			}
		}
		.frame(width: 400, height: 250)
	}
}

#Preview {
	InspectorView()
		.environment(GlobalStore())
		.frame(width: 300)
}
