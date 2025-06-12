//
//  StartingView.swift
//  SwiftFlow
//
//  Created by Kevin Perez on 5/7/25.
//

import SwiftUI
import SwiftData

struct StartingView: View {
	
	@Environment(\.modelContext) private var modelContext
	@Environment(\.openWindow) private var openWindow
	@Environment(\.dismissWindow) private var dismissWindow
	@Query(sort: \Project.id) var projects: [Project]
	@State private var showCreateProjectSheet = false
	
	var body: some View {
		HStack {
			VStack {
				Image(systemName: "app.badge.fill")
					.font(.largeTitle)
				Button {
					showCreateProjectSheet.toggle()
				} label: {
					Label("Create New App", systemImage: "plus.app")
				}
			}
			VStack {
				ForEach(projects) { project in
					HStack {
						Image(systemName: project.color.icon)
							.foregroundStyle(project.color.color)
							.background(project.color.color.opacity(0.20))
							.frame(width: 32, height: 32, alignment: .center)
							.cornerRadius(0.15)
						Text(project.name)
					}
				}
			}
		}
		.sheet(isPresented: $showCreateProjectSheet) {
			CreateProjectView()
		}
	}
}


