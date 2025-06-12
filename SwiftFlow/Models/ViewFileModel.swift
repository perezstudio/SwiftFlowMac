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
	var name: String                             // e.g. "LoginView"
	var components: [Component]
	var variables: [Variable]

	init(name: String) {
		self.name = name
		self.components = []
		self.variables = []
	}
}

@Model
class Variable {
	var name: String                      // e.g. "isLoggedIn"
	var type: String                      // e.g. "Bool", "String", "User"
	var kind: VariableKind                // e.g. .state, .binding
	var defaultValue: String?             // Optional init/default (only used by state/constant)

	init(name: String, type: String, kind: VariableKind, defaultValue: String? = nil) {
		self.name = name
		self.type = type
		self.kind = kind
		self.defaultValue = defaultValue
	}
}

enum VariableKind: String, Codable {
	case state
	case binding
	case constant
	case environment
	case observedObject
	case environmentObject
}
