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
	@Environment(GlobalStore.self) private var globalStore
	@Query(sort: \Project.name) var projects: [Project]
	@State private var showCreateProjectSheet = false
	
	var body: some View {
		HStack(spacing: 0) {
			// Left Panel - App Icon and Actions
			VStack(spacing: 24) {
				Spacer()
				
				// App Icon and Title
				VStack(spacing: 16) {
					Image(systemName: "swift")
						.font(.system(size: 80))
						.foregroundStyle(.orange)
						.background(
							RoundedRectangle(cornerRadius: 16)
								.fill(Color.orange.opacity(0.15))
								.frame(width: 120, height: 120)
						)
					
					Text("SwiftFlow")
						.font(.title)
						.fontWeight(.semibold)
				}
				
				// Create Actions
				VStack(spacing: 12) {
					Button {
						showCreateProjectSheet = true
					} label: {
						HStack {
							Image(systemName: "plus.circle.fill")
							Text("Create a new project")
						}
						.frame(maxWidth: .infinity)
						.padding(.vertical, 12)
						.background(Color.accentColor)
						.foregroundStyle(.white)
						.clipShape(RoundedRectangle(cornerRadius: 8))
					}
					.buttonStyle(.plain)
					
					Button {
						// TODO: Open existing project
					} label: {
						HStack {
							Image(systemName: "folder")
							Text("Open a project or file")
						}
						.frame(maxWidth: .infinity)
						.padding(.vertical, 12)
						.background(Color(NSColor.controlBackgroundColor))
						.foregroundStyle(.primary)
						.overlay(
							RoundedRectangle(cornerRadius: 8)
								.stroke(Color(NSColor.separatorColor), lineWidth: 1)
						)
						.clipShape(RoundedRectangle(cornerRadius: 8))
					}
					.buttonStyle(.plain)
				}
				.frame(width: 220)
				
				Spacer()
			}
			.frame(width: 540)  // 60% of 900px
			
			// Vertical Divider
			Rectangle()
				.fill(Color(NSColor.separatorColor))
				.frame(width: 1)
			
			// Right Panel - Recent Projects
			VStack(alignment: .leading, spacing: 0) {
				
				// Projects List
				if projects.isEmpty {
					VStack(spacing: 16) {
						Image(systemName: "tray")
							.font(.system(size: 48))
							.foregroundStyle(.tertiary)
						
						VStack(spacing: 8) {
							Text("No Recent Projects")
								.font(.headline)
								.foregroundStyle(.secondary)
							
							Text("Create a new project to get started")
								.font(.subheadline)
								.foregroundStyle(.tertiary)
						}
					}
					.frame(maxWidth: .infinity, maxHeight: .infinity)
				} else {
					ScrollView {
						LazyVStack(spacing: 0) {
							ForEach(projects) { project in
								ProjectRow(project: project) {
									openProject(project)
								}
							}
						}
						.padding(.horizontal, 16)
						.padding(.top, 24)
					}
				}
			}
			.frame(maxWidth: .infinity)
		}
		.frame(width: 900, height: 500)
		.background(.regularMaterial)
		.sheet(isPresented: $showCreateProjectSheet) {
			CreateProjectView()
		}
	}
	
	private func openProject(_ project: Project) {
		globalStore.selectedProject = project
		openWindow(id: "editor")
		dismissWindow(id: "project-picker")
	}
}

struct ProjectRow: View {
	let project: Project
	let action: () -> Void
	@State private var isHovered = false
	
	var body: some View {
		Button(action: action) {
			HStack(spacing: 16) {
				// Project Icon
				RoundedRectangle(cornerRadius: 8)
					.fill(project.color.color.opacity(0.2))
					.frame(width: 48, height: 48)
					.overlay(
						Image(systemName: project.icon)
							.font(.title2)
							.foregroundStyle(project.color.color)
	)
				
				// Project Info
				VStack(alignment: .leading, spacing: 4) {
					Text(project.name)
						.font(.headline)
						.foregroundStyle(.primary)
						.frame(maxWidth: .infinity, alignment: .leading)
					
					Text("SwiftUI Project")
						.font(.caption)
						.foregroundStyle(.secondary)
						.frame(maxWidth: .infinity, alignment: .leading)
				}
				
				Spacer()
				
				// Chevron
				Image(systemName: "chevron.right")
					.font(.caption)
					.foregroundStyle(.tertiary)
					.opacity(isHovered ? 1 : 0.5)
			}
			.padding(.horizontal, 16)
			.padding(.vertical, 12)
			.background(
				RoundedRectangle(cornerRadius: 12)
					.fill(isHovered ? Color(NSColor.controlAccentColor).opacity(0.08) : Color.clear)
			)
		}
		.buttonStyle(.plain)
		.onHover { hovering in
			withAnimation(.easeInOut(duration: 0.15)) {
				isHovered = hovering
			}
		}
	}
}


