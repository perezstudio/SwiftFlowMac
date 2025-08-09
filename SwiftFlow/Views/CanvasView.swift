//
//  CanvasView.swift
//  SwiftFlow
//
//  Created by Kevin Perez on 5/9/25.
//

import SwiftUI
import SwiftData

struct CanvasView: View {
	@Environment(GlobalStore.self) private var globalStore
	@Environment(\.modelContext) private var modelContext
	@State private var isTargeted = false
	
	var body: some View {
		Group {
			if let viewFile = globalStore.selectedViewFile {
				ViewCanvasContent(viewFile: viewFile, isTargeted: $isTargeted)
			} else if let modelFile = globalStore.selectedModelFile {
				ModelEditorView(modelFile: modelFile)
			} else {
				VStack(spacing: 20) {
					Image(systemName: "doc.text")
						.font(.system(size: 60))
						.foregroundStyle(.secondary)
					Text("No File Selected")
						.font(.title2)
						.foregroundStyle(.primary)
					Text("Select a file from the sidebar to begin")
						.font(.body)
						.foregroundStyle(.secondary)
				}
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(Color.gray.opacity(0.05))
	}
}

struct ViewCanvasContent: View {
	let viewFile: ViewFile
	@Binding var isTargeted: Bool
	@Environment(GlobalStore.self) private var globalStore
	@Environment(\.modelContext) private var modelContext
	@State private var deviceFrame: DeviceFrame = .iPhone15Pro
	@State private var canvasScale: CGFloat = 0.75
	
	enum DeviceFrame: String, CaseIterable {
		case iPhone15Pro = "iPhone 15 Pro"
		case iPadPro = "iPad Pro"
		case macOS = "macOS Window"
		case none = "No Frame"
		
		var size: CGSize? {
			switch self {
			case .iPhone15Pro: return CGSize(width: 393, height: 852)
			case .iPadPro: return CGSize(width: 1024, height: 1366)
			case .macOS: return CGSize(width: 800, height: 600)
			case .none: return nil
			}
		}
	}
	
	var body: some View {
		VStack(spacing: 0) {
			CanvasToolbar(deviceFrame: $deviceFrame, canvasScale: $canvasScale)
			
			ScrollView([.horizontal, .vertical]) {
				ZStack {
					if let size = deviceFrame.size {
						DeviceFrameView(deviceFrame: deviceFrame)
							.frame(width: size.width, height: size.height)
							.overlay(
								ComponentPreviewView(viewFile: viewFile)
									.frame(maxWidth: .infinity, maxHeight: .infinity)
									.background(Color.white)
									.clipShape(RoundedRectangle(cornerRadius: deviceFrame == .iPhone15Pro ? 40 : 0))
							)
							.scaleEffect(canvasScale)
					} else {
						ComponentPreviewView(viewFile: viewFile)
							.frame(minWidth: 300, minHeight: 400)
							.background(Color.white)
							.cornerRadius(8)
							.shadow(radius: 10)
							.scaleEffect(canvasScale)
					}
				}
				.padding(100)
			}
			.background(
				Pattern()
					.opacity(0.3)
			)
			.onDrop(of: [.component], isTargeted: $isTargeted) { providers in
				handleDrop(providers: providers, to: viewFile)
				return true
			}
			.overlay(
				Group {
					if isTargeted {
						RoundedRectangle(cornerRadius: 12)
							.stroke(Color.accentColor, lineWidth: 3)
							.background(Color.accentColor.opacity(0.1))
							.animation(.easeInOut, value: isTargeted)
					}
				}
			)
		}
	}
	
	private func handleDrop(providers: [NSItemProvider], to viewFile: ViewFile) {
		for provider in providers {
			provider.loadTransferable(type: ComponentTransferable.self) { result in
				switch result {
				case .success(let transferable):
					DispatchQueue.main.async {
						let newComponent = Component(type: transferable.type)
						configureDefaultProperties(for: newComponent)
						viewFile.components.append(newComponent)
						globalStore.selectedComponent = newComponent
						try? modelContext.save()
					}
				case .failure(let error):
					print("Failed to load component: \(error)")
				}
			}
		}
	}
	
	private func configureDefaultProperties(for component: Component) {
		switch component.type {
		case .text:
			component.properties.append(ComponentProperty(key: "text", value: "\"Hello, World!\""))
		case .button:
			component.properties.append(ComponentProperty(key: "action", value: "{}"))
			component.properties.append(ComponentProperty(key: "label", value: "\"Button\""))
		case .textField:
			component.properties.append(ComponentProperty(key: "placeholder", value: "\"Enter text...\""))
			component.properties.append(ComponentProperty(key: "text", value: ".constant(\"\")"))
		case .image:
			component.properties.append(ComponentProperty(key: "systemName", value: "\"photo\""))
		case .vstack, .hstack, .zstack:
			component.properties.append(ComponentProperty(key: "spacing", value: "10"))
		default:
			break
		}
	}
}

struct CanvasToolbar: View {
	@Binding var deviceFrame: ViewCanvasContent.DeviceFrame
	@Binding var canvasScale: CGFloat
	
	var body: some View {
		HStack {
			Picker("Device", selection: $deviceFrame) {
				ForEach(ViewCanvasContent.DeviceFrame.allCases, id: \.self) { frame in
					Text(frame.rawValue).tag(frame)
				}
			}
			.pickerStyle(.menu)
			.frame(width: 150)
			
			Divider()
				.frame(height: 20)
			
			HStack(spacing: 4) {
				Button {
					withAnimation {
						canvasScale = max(0.25, canvasScale - 0.1)
					}
				} label: {
					Image(systemName: "minus.magnifyingglass")
				}
				
				Text("\(Int(canvasScale * 100))%")
					.monospacedDigit()
					.frame(width: 50)
				
				Button {
					withAnimation {
						canvasScale = min(2.0, canvasScale + 0.1)
					}
				} label: {
					Image(systemName: "plus.magnifyingglass")
				}
				
				Button {
					withAnimation {
						canvasScale = 1.0
					}
				} label: {
					Text("Reset")
						.font(.caption)
				}
			}
			
			Spacer()
			
			Button {
				print("Run Preview")
			} label: {
				Label("Run", systemImage: "play.fill")
			}
			.buttonStyle(.borderedProminent)
		}
		.padding(.horizontal)
		.padding(.vertical, 8)
		.background(Color(NSColor.controlBackgroundColor))
		.overlay(alignment: .bottom) {
			Divider()
		}
	}
}

struct DeviceFrameView: View {
	let deviceFrame: ViewCanvasContent.DeviceFrame
	
	var body: some View {
		ZStack {
			switch deviceFrame {
			case .iPhone15Pro:
				RoundedRectangle(cornerRadius: 50)
					.fill(Color.black)
					.overlay(
						RoundedRectangle(cornerRadius: 50)
							.stroke(Color.gray.opacity(0.3), lineWidth: 1)
					)
					.overlay(alignment: .top) {
						Capsule()
							.fill(Color.black)
							.frame(width: 150, height: 30)
							.offset(y: 10)
					}
			case .iPadPro:
				RoundedRectangle(cornerRadius: 20)
					.fill(Color.black)
					.overlay(
						RoundedRectangle(cornerRadius: 20)
							.stroke(Color.gray.opacity(0.3), lineWidth: 1)
					)
			case .macOS:
				RoundedRectangle(cornerRadius: 10)
					.fill(Color(NSColor.windowBackgroundColor))
					.overlay(
						RoundedRectangle(cornerRadius: 10)
							.stroke(Color.gray.opacity(0.3), lineWidth: 1)
					)
					.overlay(alignment: .top) {
						HStack(spacing: 8) {
							Circle().fill(Color.red).frame(width: 12, height: 12)
							Circle().fill(Color.yellow).frame(width: 12, height: 12)
							Circle().fill(Color.green).frame(width: 12, height: 12)
						}
						.padding(10)
						.frame(maxWidth: .infinity, alignment: .leading)
					}
			case .none:
				EmptyView()
			}
		}
	}
}

struct Pattern: View {
	var body: some View {
		GeometryReader { geometry in
			Path { path in
				let size: CGFloat = 20
				let rows = Int(geometry.size.height / size) + 1
				let cols = Int(geometry.size.width / size) + 1
				
				for row in 0..<rows {
					for col in 0..<cols {
						let x = CGFloat(col) * size
						let y = CGFloat(row) * size
						path.addEllipse(in: CGRect(x: x, y: y, width: 2, height: 2))
					}
				}
			}
			.fill(Color.gray.opacity(0.3))
		}
	}
}

struct ComponentPreviewView: View {
	let viewFile: ViewFile
	@Environment(GlobalStore.self) private var globalStore
	
	var body: some View {
		ScrollView {
			VStack(spacing: 0) {
				if viewFile.components.isEmpty {
					VStack(spacing: 20) {
						Image(systemName: "rectangle.dashed")
							.font(.system(size: 60))
							.foregroundStyle(.secondary)
						Text("Empty Canvas")
							.font(.title2)
							.foregroundStyle(.primary)
						Text("Drag components here to start building")
							.font(.body)
							.foregroundStyle(.secondary)
					}
					.frame(minHeight: 400)
				} else {
					VStack(spacing: 10) {
						ForEach(viewFile.components) { component in
							ComponentView(component: component)
								.onTapGesture {
									globalStore.selectedComponent = component
								}
								.overlay(
									Group {
										if globalStore.selectedComponent == component {
											RoundedRectangle(cornerRadius: 4)
												.stroke(Color.accentColor, lineWidth: 2)
										}
									}
								)
						}
					}
					.padding()
				}
			}
		}
	}
}

struct ComponentView: View {
	let component: Component
	@Environment(GlobalStore.self) private var globalStore
	
	var body: some View {
		Group {
			switch component.type {
			case .text:
				Text(getPropertyValue("text") ?? "Text")
					.applyModifiers(component.modifiers)
			case .button:
				Button(getPropertyValue("label") ?? "Button") {
					print("Button tapped")
				}
				.applyModifiers(component.modifiers)
			case .textField:
				TextField(getPropertyValue("placeholder") ?? "", text: .constant(""))
					.applyModifiers(component.modifiers)
			case .image:
				Image(systemName: getPropertyValue("systemName") ?? "photo")
					.applyModifiers(component.modifiers)
			case .vstack:
				VStack(spacing: CGFloat(Int(getPropertyValue("spacing") ?? "10") ?? 10)) {
					ForEach(component.children) { child in
						ComponentView(component: child)
					}
				}
				.applyModifiers(component.modifiers)
			case .hstack:
				HStack(spacing: CGFloat(Int(getPropertyValue("spacing") ?? "10") ?? 10)) {
					ForEach(component.children) { child in
						ComponentView(component: child)
					}
				}
				.applyModifiers(component.modifiers)
			case .zstack:
				ZStack {
					ForEach(component.children) { child in
						ComponentView(component: child)
					}
				}
				.applyModifiers(component.modifiers)
			case .spacer:
				Spacer()
					.applyModifiers(component.modifiers)
			case .customView:
				if let referencedView = component.referencedView {
					ComponentPreviewView(viewFile: referencedView)
						.applyModifiers(component.modifiers)
				} else {
					Text("Custom View")
						.foregroundStyle(.secondary)
						.applyModifiers(component.modifiers)
				}
			}
		}
	}
	
	private func getPropertyValue(_ key: String) -> String? {
		component.properties.first(where: { $0.key == key })?.value.replacingOccurrences(of: "\"", with: "")
	}
}

extension View {
	func applyModifiers(_ modifiers: [Modifier]) -> some View {
		var result = AnyView(self)
		
		for modifier in modifiers {
			switch modifier.name {
			case "padding":
				if let value = modifier.arguments.first?.value,
				   let padding = Double(value) {
					result = AnyView(result.padding(padding))
				} else {
					result = AnyView(result.padding())
				}
			case "foregroundColor", "foregroundStyle":
				if let colorName = modifier.arguments.first?.value {
					result = AnyView(result.foregroundStyle(colorFromString(colorName)))
				}
			case "font":
				if let fontName = modifier.arguments.first?.value {
					result = AnyView(result.font(fontFromString(fontName)))
				}
			case "frame":
				var width: CGFloat?
				var height: CGFloat?
				for arg in modifier.arguments {
					if arg.name == "width", let w = Double(arg.value) {
						width = w
					} else if arg.name == "height", let h = Double(arg.value) {
						height = h
					}
				}
				result = AnyView(result.frame(width: width, height: height))
			case "background":
				if let colorName = modifier.arguments.first?.value {
					result = AnyView(result.background(colorFromString(colorName)))
				}
			case "cornerRadius":
				if let value = modifier.arguments.first?.value,
				   let radius = Double(value) {
					result = AnyView(result.cornerRadius(radius))
				}
			default:
				break
			}
		}
		
		return result
	}
	
	private func colorFromString(_ string: String) -> Color {
		switch string.lowercased().replacingOccurrences(of: ".", with: "") {
		case "red": return .red
		case "blue": return .blue
		case "green": return .green
		case "yellow": return .yellow
		case "orange": return .orange
		case "purple": return .purple
		case "pink": return .pink
		case "gray", "grey": return .gray
		case "black": return .black
		case "white": return .white
		case "clear": return .clear
		case "accentcolor": return .accentColor
		default: return .primary
		}
	}
	
	private func fontFromString(_ string: String) -> Font {
		switch string.lowercased().replacingOccurrences(of: ".", with: "") {
		case "largetitle": return .largeTitle
		case "title": return .title
		case "title2": return .title2
		case "title3": return .title3
		case "headline": return .headline
		case "subheadline": return .subheadline
		case "body": return .body
		case "callout": return .callout
		case "footnote": return .footnote
		case "caption": return .caption
		case "caption2": return .caption2
		default: return .body
		}
	}
}

struct ModelEditorView: View {
	let modelFile: ModelFile
	@Environment(\.modelContext) private var modelContext
	@State private var showingAddField = false
	@State private var newFieldName = ""
	@State private var newFieldType = "String"
	@State private var newFieldDefault = ""
	
	let fieldTypes = ["String", "Int", "Double", "Bool", "Date", "UUID"]
	
	var body: some View {
		VStack(alignment: .leading, spacing: 20) {
			HStack {
				Image(systemName: "cylinder.split.1x2")
					.font(.largeTitle)
					.foregroundStyle(.green)
				
				VStack(alignment: .leading) {
					Text(modelFile.name)
						.font(.title)
						.bold()
					
					Text("SwiftData Model")
						.foregroundStyle(.secondary)
				}
				
				Spacer()
				
				Button {
					showingAddField = true
				} label: {
					Label("Add Field", systemImage: "plus.circle")
				}
			}
			.padding()
			
			Divider()
			
			if modelFile.fields.isEmpty {
				VStack(spacing: 20) {
					Image(systemName: "rectangle.stack.badge.plus")
						.font(.system(size: 60))
						.foregroundStyle(.secondary)
					Text("No Fields")
						.font(.title2)
						.foregroundStyle(.primary)
					Text("Add fields to define your model")
						.font(.body)
						.foregroundStyle(.secondary)
				}
			} else {
				List {
					ForEach(modelFile.fields) { field in
						HStack {
							Image(systemName: "chevron.left.forwardslash.chevron.right")
								.foregroundStyle(.blue)
							
							Text(field.name)
								.font(.system(.body, design: .monospaced))
							
							Text(":")
								.foregroundStyle(.secondary)
							
							Text(field.type)
								.font(.system(.body, design: .monospaced))
								.foregroundStyle(.purple)
							
							if let defaultValue = field.defaultValue, !defaultValue.isEmpty {
								Text("= \(defaultValue)")
									.font(.system(.body, design: .monospaced))
									.foregroundStyle(.secondary)
							}
							
							Spacer()
						}
						.padding(.vertical, 4)
					}
					.onDelete { offsets in
						for index in offsets {
							modelContext.delete(modelFile.fields[index])
						}
						modelFile.fields.remove(atOffsets: offsets)
						try? modelContext.save()
					}
				}
			}
			
			Spacer()
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(Color(NSColor.controlBackgroundColor))
		.sheet(isPresented: $showingAddField) {
			AddFieldSheet(
				fieldName: $newFieldName,
				fieldType: $newFieldType,
				fieldDefault: $newFieldDefault,
				fieldTypes: fieldTypes
			) {
				let field = ModelField(
					name: newFieldName,
					type: newFieldType,
					defaultValue: newFieldDefault.isEmpty ? nil : newFieldDefault
				)
				modelFile.fields.append(field)
				try? modelContext.save()
				
				newFieldName = ""
				newFieldType = "String"
				newFieldDefault = ""
				showingAddField = false
			}
		}
	}
}

struct AddFieldSheet: View {
	@Binding var fieldName: String
	@Binding var fieldType: String
	@Binding var fieldDefault: String
	let fieldTypes: [String]
	let onAdd: () -> Void
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		NavigationStack {
			Form {
				TextField("Field Name", text: $fieldName)
				
				Picker("Type", selection: $fieldType) {
					ForEach(fieldTypes, id: \.self) { type in
						Text(type).tag(type)
					}
				}
				
				TextField("Default Value (Optional)", text: $fieldDefault)
			}
			.padding()
			.navigationTitle("Add Field")
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
					.disabled(fieldName.isEmpty)
				}
			}
		}
		.frame(width: 400, height: 250)
	}
}

#Preview {
	CanvasView()
		.environment(GlobalStore())
}
