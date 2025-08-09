//
//  ModelFileModel.swift
//  SwiftFlow
//
//  Created by Kevin Perez on 5/7/25.
//

import SwiftUI
import SwiftData

@Model
class ModelFile {
	var id: UUID
	var name: String
	var fields: [ModelField]

	init(name: String) {
		self.id = UUID()
		self.name = name
		self.fields = []
	}
}

@Model
class ModelField {
	var id: UUID
	var name: String
	var type: String
	var defaultValue: String?

	init(name: String, type: String, defaultValue: String? = nil) {
		self.id = UUID()
		self.name = name
		self.type = type
		self.defaultValue = defaultValue
	}
}
