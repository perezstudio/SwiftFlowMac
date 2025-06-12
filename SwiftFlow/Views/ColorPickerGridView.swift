//
//  ColorPickerGridView.swift
//  SwiftFlow
//
//  Created by Kevin Perez on 5/8/25.
//

import SwiftUI
import SwiftData

struct ColorPickerGridView: View {
	
	@Binding var selectedColor: ProjectColor
	private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 5)

	var body: some View {
		LazyVGrid(columns: columns, spacing: 16) {
			ForEach(ProjectColor.allCases) { color in
				Button(action: {
					selectedColor = color
				}) {
					Circle()
						.fill(color.color)
						.frame(width: 24, height: 24)
						.overlay(
							Circle()
								.stroke(Color.primary.opacity(selectedColor == color ? 0.8 : 0.1), lineWidth: 3)
						)
						.overlay(
							Group {
								if selectedColor == color {
									Image(systemName: "checkmark")
										.foregroundColor(.white)
										.font(.caption)
								}
							}
						)
				}
				.buttonStyle(.plain)
			}
		}
		.padding()
	}
}
