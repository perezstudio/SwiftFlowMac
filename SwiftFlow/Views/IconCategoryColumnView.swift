//
//  IconCategoryColumnView.swift
//  SwiftFlow
//
//  Created by Kevin Perez on 5/8/25.
//

import SwiftUI
import SwiftData

struct IconCategoryColumnView: View {
	
	@Binding var selectedIcon: String
	let category: IconCategory
	private let rows = 4
	private let iconSize: CGFloat = 48

	private var rowWiseIcons: [[String]] {
		var rowsArray = Array(repeating: [String](), count: rows)
		for (index, icon) in category.icons.enumerated() {
			rowsArray[index % rows].append(icon)
		}
		return rowsArray
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text(category.name)
				.font(.headline)
				.padding(.horizontal)

			ScrollView(.horizontal, showsIndicators: false) {
				HStack(alignment: .top, spacing: 16) {
					ForEach(rowWiseIcons[0].indices, id: \.self) { columnIndex in
						VStack(spacing: 16) {
							ForEach(0..<rows, id: \.self) { rowIndex in
								if rowWiseIcons[rowIndex].indices.contains(columnIndex) {
									Image(systemName: rowWiseIcons[rowIndex][columnIndex])
										.font(.headline)
										.padding(6)
										.foregroundStyle(rowWiseIcons[rowIndex][columnIndex] == selectedIcon ? Color.primary : .secondary)
										.background(.ultraThinMaterial)
										.clipShape(Circle())
										.onTapGesture {
											selectedIcon = rowWiseIcons[rowIndex][columnIndex]
										}
								}
							}
						}
					}
				}
				.padding(.horizontal)
			}
		}
	}
}
