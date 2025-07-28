//
//  TaskDetailView.swift
//  FlowTrack
//
//  Created by Rajeev  Upadhyay on 28/07/25.
//

import SwiftUI

struct TaskDetailView: View {
    @ObservedObject var task: Task
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingEditView = false
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text(task.wrappedTitle)
                        .font(.title)
                    Spacer()
                    Circle()
                        .fill(task.priorityEnum.color)
                        .frame(width: 20, height: 20)
                }
                
                if !task.wrappedDescription.isEmpty {
                    Text(task.wrappedDescription)
                        .padding(.vertical)
                }
            }
            
            Section("Details") {
                HStack {
                    Image(systemName: TaskCategory(rawValue: task.wrappedCategory)?.icon ?? "questionmark")
                    Text(task.wrappedCategory)
                }
                
                HStack {
                    Image(systemName: "calendar")
                    Text(task.wrappedDueDate.formatted(date: .abbreviated, time: .shortened))
                        .foregroundColor(task.wrappedDueDate < Date() && !task.isCompleted ? .red : .primary)
                }
                
                if !task.tagArray.isEmpty {
                    HStack {
                        Image(systemName: "tag")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(task.tagArray, id: \.self) { tag in
                                    Text(tag)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                }
            }
            
            Section {
                Button {
                    task.isCompleted.toggle()
                    do {
                        try viewContext.save()
                    } catch {
                        print("Error toggling completion: \(error)")
                    }
                } label: {
                    Label(
                        task.isCompleted ? "Mark Incomplete" : "Mark Complete",
                        systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark"
                    )
                    .foregroundColor(task.isCompleted ? .yellow : .green)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingEditView = true
                } label: {
                    Text("Edit")
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            AddEditTaskView(taskToEdit: task)
        }
    }
}
