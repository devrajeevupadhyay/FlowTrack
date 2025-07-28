//
//  AddEditTask.swift
//  FlowTrack
//
//  Created by Rajeev  Upadhyay on 28/07/25.
//

import SwiftUI

struct AddEditTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var taskDescription = ""
    @State private var dueDate = Date()
    @State private var priority: TaskPriority = .medium
    @State private var category: TaskCategory = .personal
    @State private var tags: [String] = []
    @State private var newTag = ""
    @State private var showDatePicker = false
    
    var taskToEdit: Task?
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $taskDescription, axis: .vertical)
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Picker("Category", selection: $category) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon).tag(category)
                        }
                    }
                }
                
                Section(header: Text("Due Date & Time")) {
                    Button {
                        showDatePicker.toggle()
                    } label: {
                        HStack {
                            Text("Due Date")
                            Spacer()
                            Text(dueDate.formatted(date: .abbreviated, time: .shortened))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if showDatePicker {
                        DatePicker(
                            "Select Date",
                            selection: $dueDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.graphical)
                    }
                }
                
                Section(header: Text("Tags")) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                    }
                    .onDelete { indices in
                        tags.remove(atOffsets: indices)
                    }
                    
                    HStack {
                        TextField("Add Tag", text: $newTag)
                        Button {
                            withAnimation {
                                if !newTag.isEmpty && !tags.contains(newTag) {
                                    tags.append(newTag)
                                    newTag = ""
                                }
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .disabled(newTag.isEmpty)
                    }
                }
            }
            .navigationTitle(taskToEdit == nil ? "Add Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTask()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                if let task = taskToEdit {
                    title = task.wrappedTitle
                    taskDescription = task.wrappedDescription
                    dueDate = task.wrappedDueDate
                    priority = task.priorityEnum
                    category = TaskCategory(rawValue: task.wrappedCategory) ?? .personal
                    tags = task.tagArray
                }
            }
        }
    }
    
    private func saveTask() {
        let task = taskToEdit ?? Task(context: viewContext)
        task.id = taskToEdit?.id ?? UUID()
        task.title = title
        task.taskDescription = taskDescription
        task.dueDate = dueDate
        task.priority = priority.rawValue
        task.category = category.rawValue
        task.tagArray = tags
        task.createdAt = taskToEdit?.createdAt ?? Date()
        
        do {
            try viewContext.save()
            scheduleNotification(for: task)
        } catch {
            print("Error saving task: \(error)")
        }
    }
    
    private func scheduleNotification(for task: Task) {
        let content = UNMutableNotificationContent()
        content.title = "Task Due: \(task.wrappedTitle)"
        content.body = task.wrappedDescription.isEmpty ? "Your task is due now" : task.wrappedDescription
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: task.wrappedDueDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: task.id?.uuidString ?? UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}
