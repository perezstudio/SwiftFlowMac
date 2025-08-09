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
	var referencedView: ViewFile?
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
	var id: UUID
	var key: String
	var value: String

	init(key: String, value: String) {
		self.id = UUID()
		self.key = key
		self.value = value
	}
}

@Model
class Modifier {
	var id: UUID
	var name: String
	var arguments: [ModifierArgument]

	init(name: String) {
		self.id = UUID()
		self.name = name
		self.arguments = []
	}
}

@Model
class ModifierArgument {
	var id: UUID
	var name: String?
	var value: String

	init(name: String? = nil, value: String) {
		self.id = UUID()
		self.name = name
		self.value = value
	}
}

public enum ComponentType: String, Codable, CaseIterable {
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
