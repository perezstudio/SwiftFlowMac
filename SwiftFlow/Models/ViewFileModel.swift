//
//  ViewFileModel.swift
//  SwiftFlow
//
//  Created by Kevin Perez on 5/7/25.
//

import SwiftUI
import SwiftData

@Model
class ViewFile {
	var id: UUID
	var name: String
	var components: [Component]
	var variables: [Variable]

	init(name: String) {
		self.id = UUID()
		self.name = name
		self.components = []
		self.variables = []
	}
}

@Model
class Variable {
	var id: UUID
	var name: String
	var type: String
	var kind: VariableKind
	var defaultValue: String?

	init(name: String, type: String, kind: VariableKind, defaultValue: String? = nil) {
		self.id = UUID()
		self.name = name
		self.type = type
		self.kind = kind
		self.defaultValue = defaultValue
	}
}

enum VariableKind: String, Codable, CaseIterable {
	case state
	case binding
	case constant
	case environment
	case observedObject
	case environmentObject
}
