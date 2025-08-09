//
//  ProjectModel.swift
//  SwiftFlow
//
//  Created by Kevin Perez on 5/7/25.
//

import SwiftUI
import SwiftData

@Model
class Project {
	var id: UUID
	var name: String
	var icon: String
	var color: ProjectColor
	@Relationship(deleteRule: .cascade) var viewFiles: [ViewFile]
	@Relationship(deleteRule: .cascade) var modelFiles: [ModelFile]

	init(name: String, icon: String, color: ProjectColor) {
		self.id = UUID()
		self.name = name
		self.icon = icon
		self.color = color
		self.viewFiles = []
		self.modelFiles = []
	}
}
