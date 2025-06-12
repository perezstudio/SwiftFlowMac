//
//  ComponentModel.swift
//  SwiftFlow
//
//  Created by Kevin Perez on 5/7/25.
//

import SwiftUI
import SwiftData

@Model
class Component {
	var id: UUID
	var type: ComponentType
	var properties: [ComponentProperty]
	var children: [Component]
	var referencedView: ViewFile?                // For embedded custom views
	var modifiers: [Modifier]

	init(type: ComponentType) {
		self.id = UUID()
		self.type = type
		self.properties = []
		self.children = []
		self.modifiers = []
	}
}

@Model
class ComponentProperty {
	var key: String           // e.g. "text", "alignment"
	var value: String         // e.g. "\"Hello\"", ".center"

	init(key: String, value: String) {
		self.key = key
		self.value = value
	}
}

@Model
class Modifier {
	var name: String                          // e.g. "padding"
	var arguments: [ModifierArgument]

	init(name: String) {
		self.name = name
		self.arguments = []
	}
}

@Model
class ModifierArgument {
	var name: String?                         // Optional named arg (e.g. "edge")
	var value: String                         // e.g. ".leading", "8", ".title"

	init(name: String? = nil, value: String) {
		self.name = name
		self.value = value
	}
}

public enum ComponentType: String, Codable {
	case text
	case image
	case vstack
	case hstack
	case zstack
	case spacer
	case button
	case textField
	case customView
}
