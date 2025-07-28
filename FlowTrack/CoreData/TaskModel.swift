//
//  TaskModel.swift
//  FlowTrack
//
//  Created by Rajeev  Upadhyay on 28/07/25.
//

import Foundation
import CoreData
import SwiftUICore

extension Task {
    var priorityEnum: TaskPriority {
        get {
            TaskPriority(rawValue: priority ?? "") ?? .medium
        }
        set {
            priority = newValue.rawValue
        }
    }
    
    var wrappedDueDate: Date {
        dueDate ?? Date()
    }
    
    var wrappedTitle: String {
        title ?? "Untitled Task"
    }
    
    var wrappedDescription: String {
        taskDescription ?? ""
    }
    
    var wrappedCategory: String {
        category ?? "Uncategorized"
    }
    
    var tagArray: [String] {
        get {
            tags as? [String] ?? []
        }
        set {
            tags = newValue as NSObject
        }
    }
    
    static func fetchAllTasks() -> NSFetchRequest<Task> {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Task.dueDate, ascending: true)]
        return request
    }
}

enum TaskPriority: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .red
        }
    }
}

enum TaskCategory: String, CaseIterable {
    case work = "Work"
    case personal = "Personal"
    case shopping = "Shopping"
    case health = "Health"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .work: return "briefcase"
        case .personal: return "person"
        case .shopping: return "cart"
        case .health: return "heart"
        case .other: return "questionmark"
        }
    }
}
