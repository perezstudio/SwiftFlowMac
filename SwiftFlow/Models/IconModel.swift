//
//  IconModel.swift
//  SwiftFlow
//
//  Created by Kevin Perez on 5/8/25.
//

import SwiftUI

struct IconCategory: Identifiable, Codable, Hashable {
	let id: String             // e.g. "nature"
	let name: String           // e.g. "Nature"
	let icons: [String]        // SF Symbols (e.g. ["leaf.fill", "tortoise.fill"])
}

let iconCategories: [IconCategory] = [
	IconCategory(id: "nature", name: "Nature", icons: [
		"leaf.fill", "tortoise.fill", "hare.fill", "ant.fill", "ladybug.fill", "tree.fill"
	]),
	IconCategory(id: "weather", name: "Weather", icons: [
		"cloud.fill", "cloud.rain.fill", "cloud.sun.fill", "wind", "sun.max.fill", "snowflake"
	]),
	IconCategory(id: "symbols", name: "Symbols", icons: [
		"star.fill", "heart.fill", "flag.fill", "bell.fill", "bookmark.fill", "bolt.fill"
	])
]
