//
//  ContentView.swift
//  FlowTrack
//
//  Created by Rajeev  Upadhyay on 28/07/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddTask = false
    @State private var selectedFilter: TaskFilter = .all
    @State private var selectedSort: TaskSort = .dueDate
    @State private var searchText = ""
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.dueDate, ascending: true)],
        animation: .default)
    private var tasks: FetchedResults<Task>
    
    var filteredTasks: [Task] {
        var result = Array(tasks)
        
        // Apply filter
        switch selectedFilter {
        case .all: break
        case .completed: result = result.filter { $0.isCompleted }
        case .incomplete: result = result.filter { !$0.isCompleted }
        case .today: result = result.filter { Calendar.current.isDateInToday($0.wrappedDueDate) }
        case .overdue: result = result.filter { $0.wrappedDueDate < Date() && !$0.isCompleted }
        default : print("No Case")
            
      }
        
        // Apply search
        if !searchText.isEmpty {
            result = result.filter {
                $0.wrappedTitle.localizedCaseInsensitiveContains(searchText) ||
                $0.wrappedDescription.localizedCaseInsensitiveContains(searchText) ||
                $0.tagArray.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }
        
        // Apply sort
        switch selectedSort {
        case .dueDate: result.sort { $0.wrappedDueDate < $1.wrappedDueDate }
        case .priority: result.sort { $0.priorityEnum.rawValue > $1.priorityEnum.rawValue }
        case .title: result.sort { $0.wrappedTitle < $1.wrappedTitle }
        case .creationDate: result.sort { $0.createdAt ?? Date() > $1.createdAt ?? Date() }
        }
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredTasks, id: \.id) { task in
                    TaskRowView(task: task)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                deleteTask(task)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                toggleTaskCompletion(task)
                            } label: {
                                Label(task.isCompleted ? "Mark Incomplete" : "Complete",
                                      systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark")
                            }
                            .tint(task.isCompleted ? .yellow : .green)
                        }
                }
            }
            .navigationTitle("Tasks")
            .searchable(text: $searchText, prompt: "Search tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                       
                        Picker("Filter", selection: $selectedFilter) {
                            ForEach(TaskFilter.allCases) { filter in
                                Text(filter.rawValue).tag(filter)
                            }
                        }
                        Picker("Sort", selection: $selectedSort) {
                            ForEach(TaskSort.allCases) { sort in
                                Text(sort.rawValue).tag(sort)
                            }
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddTask.toggle()
                    } label: {
                        Label("Add Task", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddEditTaskView()
            }
        }
    }
    
    private func deleteTask(_ task: Task) {
        viewContext.delete(task)
        do {
            try viewContext.save()
        } catch {
            print("Error deleting task: \(error)")
        }
    }
    
    private func toggleTaskCompletion(_ task: Task) {
        task.isCompleted.toggle()
        do {
            try viewContext.save()
        } catch {
            print("Error toggling task completion: \(error)")
        }
    }
}

enum TaskFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case completed = "Completed"
    case incomplete = "Incomplete"
    case today = "Today"
    case overdue = "Overdue"
    case work = "Work"
    case personal = "Personal"
    case shopping = "Shopping"
    
    var id: String { self.rawValue }
//    
//    static var allCases: [TaskFilter] {
//        [.all, .completed, .incomplete, .today, .overdue] +
//        TaskCategory.allCases.map { .category($0.rawValue) }
//    }
//    
//    case category(String)
}


enum TaskSort: String, CaseIterable, Identifiable {
    case dueDate = "Due Date"
    case priority = "Priority"
    case title = "Title"
    case creationDate = "Creation Date"
    
    var id: String { self.rawValue }
}

struct TaskRowView: View {
    @ObservedObject var task: Task
    
    var body: some View {
        NavigationLink {
            TaskDetailView(task: task)
        } label: {
            HStack {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .secondary)
                    .onTapGesture {
                        task.isCompleted.toggle()
                        try? task.managedObjectContext?.save()
                    }
                
                VStack(alignment: .leading) {
                    Text(task.wrappedTitle)
                        .font(.headline)
                        .strikethrough(task.isCompleted)
                    
                    if !task.wrappedDescription.isEmpty {
                        Text(task.wrappedDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .strikethrough(task.isCompleted)
                    }
                    
                    HStack {
                        if task.wrappedDueDate < Date() && !task.isCompleted {
                            Text("Overdue")
                                .font(.caption2)
                                .padding(4)
                                .background(Color.red.opacity(0.2))
                                .cornerRadius(4)
                        }
                        
                        Text(task.wrappedDueDate.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(task.wrappedDueDate < Date() && !task.isCompleted ? .red : .secondary)
                    }
                }
                
                Spacer()
                
                Circle()
                    .fill(task.priorityEnum.color)
                    .frame(width: 12, height: 12)
                
                Image(systemName: TaskCategory(rawValue: task.wrappedCategory)?.icon ?? "questionmark")
                    .foregroundColor(.secondary)
            }
        }
    }
}
