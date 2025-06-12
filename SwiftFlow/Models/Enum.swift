//
//  Enum.swift
//  SwiftFlow
//
//  Created by Kevin Perez on 5/8/25.
//

import SwiftUI

enum ProjectColor: String, CaseIterable, Codable, Identifiable {
	case red
	case orange
	case yellow
	case green
	case teal
	case blue
	case indigo
	case purple
	case pink
	case gray

	var id: String { self.rawValue }

	var color: Color {
		switch self {
			case .red: return .red
			case .orange: return .orange
			case .yellow: return .yellow
			case .green: return .green
			case .teal: return .teal
			case .blue: return .blue
			case .indigo: return .indigo
			case .purple: return .purple
			case .pink: return .pink
			case .gray: return .gray
		}
	}

	var name: String {
		self.rawValue.capitalized
	}

	var icon: String {
		switch self {
			case .red: return "flame.fill"
			case .orange: return "sun.max.fill"
			case .yellow: return "lightbulb.fill"
			case .green: return "leaf.fill"
			case .teal: return "drop.fill"
			case .blue: return "cloud.fill"
			case .indigo: return "moon.fill"
			case .purple: return "sparkles"
			case .pink: return "heart.fill"
			case .gray: return "circle"
		}
	}
}
