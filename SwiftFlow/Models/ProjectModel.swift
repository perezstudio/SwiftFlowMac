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
	var name: String
	var icon: String
	var color: ProjectColor
	var viewFiles: [ViewFile]
	var modelFiles: [ModelFile]

	init(name: String, icon: String, color: ProjectColor) {
		self.name = name
		self.icon = icon
		self.color = color
		self.viewFiles = []
		self.modelFiles = []
	}
}
