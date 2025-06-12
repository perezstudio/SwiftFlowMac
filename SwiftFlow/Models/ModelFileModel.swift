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
	var name: String
	var fields: [ModelField]

	init(name: String) {
		self.name = name
		self.fields = []
	}
}

@Model
class ModelField {
	var name: String                             // e.g. "firstName"
	var type: String                             // e.g. "String", "Int", "Date"
	var defaultValue: String?                    // e.g. "\"John\"", "0", "Date.now"

	init(name: String, type: String, defaultValue: String? = nil) {
		self.name = name
		self.type = type
		self.defaultValue = defaultValue
	}
}
