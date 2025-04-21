//
//  EditGoalView.swift
//  TestToDoList
//
//  Created by Tom Roney on 27/09/2024.
//

import SwiftUI

struct EditGoalView: View {
    @ObservedObject var viewModel: GoalsViewModel
    
    // Instead of binding to the goal in the array, keep a local copy:
    @State private var localGoal: UserGoal
    
    @Environment(\.dismiss) var dismiss
    
    // For the inline calendar popups
    @State private var showStartDatePicker = false
    @State private var showEndDatePicker = false
    
    @State private var showDeleteConfirmation = false
    @State private var showError: Bool = false  // For title error
    @State private var showKeyActionError: Bool = false  // For key action error
    
    @Environment(\.colorScheme) var colorScheme
    
    // Custom init to receive the original goal, but store it locally
    init(viewModel: GoalsViewModel, goal: UserGoal) {
        self.viewModel = viewModel
        _localGoal = State(initialValue: goal)
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // Title
                    HStack {
                        Text("Edit Goal")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    
                    // Goal Title Field
                    TextField("What do you want to achieve?", text: $localGoal.title)
                        .padding()
                        .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("GreenButton"), lineWidth: 1)
                        )
                    
                    // Error message if title is empty
                    if showError && localGoal.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("Title is required.")
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.leading, 5)
                    }
                    
                    // Start Date Button
                    Button(action: { showStartDatePicker = true }) {
                        HStack {
                            Text("Start Date: \(formattedDate(localGoal.startDate))")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Spacer()
                            Image(systemName: "calendar")
                                .foregroundColor(Color("GreenButton"))
                        }
                        .padding()
                        .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("GreenButton"), lineWidth: 1)
                        )
                    }
                    
                    // End Date Button
                    Button(action: { showEndDatePicker = true }) {
                        HStack {
                            Text("Due Date: \(formattedDate(localGoal.endDate))")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Spacer()
                            Image(systemName: "calendar")
                                .foregroundColor(Color("GreenButton"))
                        }
                        .padding()
                        .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("GreenButton"), lineWidth: 1)
                        )
                    }
                    
                    // Validation message if end date < start date
                    if localGoal.endDate < localGoal.startDate {
                        Text("Please select a date in advance of the selected Start Date")
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.leading, 5)
                    }
                    
                    // Goal Type (optional)
                    Menu {
                        Picker(selection: Binding<String>(
                            get: { localGoal.goalType ?? "Type" },
                            set: { localGoal.goalType = $0 == "Type" ? nil : $0 }
                        ), label: EmptyView()) {
                            Text("Personal").tag("Personal")
                            Text("Professional").tag("Professional")
                        }
                    } label: {
                        HStack {
                            Text(localGoal.goalType ?? "Type")
                                .foregroundColor(localGoal.goalType == nil ? .gray : (colorScheme == .dark ? .white : .black))
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("GreenButton"), lineWidth: 1)
                        )
                    }
                    
                    // Key Actions Section
                    KeyActionSection(keyActions: $localGoal.keyActions) {
                        // If you want toggles to update Firestore immediately:
                        viewModel.updateGoal(localGoal)
                    }
                    
                    // Key Actions Error Message
                    if showKeyActionError && localGoal.keyActions.contains(where: { $0.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                        Text("Please fill in all key action fields or remove empty key actions.")
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.leading, 5)
                    }
                    
                    // Progress Section
                    ProgressSection(
                        currentValue: $localGoal.currentValue,
                        targetValue: $localGoal.targetValue,
                        onProgressChange: updateProgress
                    )
                    
                    // Buttons
                    HStack {
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            Text("Delete Goal")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // Reset error states
                            showError = false
                            showKeyActionError = false
                            
                            // Validate title
                            if localGoal.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                showError = true
                            }
                            // Validate key actions
                            if !localGoal.keyActions.isEmpty &&
                               localGoal.keyActions.contains(where: {
                                   $0.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                               }) {
                                showKeyActionError = true
                            }
                            
                            // If any error, do not save changes
                            if showError || showKeyActionError {
                                return
                            }
                            
                            saveGoal()
                        }) {
                            Text("Save Changes")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    (localGoal.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                                     (!localGoal.keyActions.isEmpty && localGoal.keyActions.contains(where: { $0.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }))
                                    ) ? Color.gray : Color("GreenButton")
                                )
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(
                            localGoal.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                            (!localGoal.keyActions.isEmpty && localGoal.keyActions.contains(where: { $0.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }))
                        )
                    }
                    .padding(.top)
                }
                .padding()
            }
            .clipped(antialiased: false)
            
            // Inline Date Pickers
            if showStartDatePicker {
                InlineDatePickerOverlay(
                    date: $localGoal.startDate,
                    label: "Start Date",
                    isPresented: $showStartDatePicker
                )
                .zIndex(999)
            }
            
            if showEndDatePicker {
                InlineDatePickerOverlay(
                    date: $localGoal.endDate,
                    label: "Due Date",
                    dateRange: localGoal.startDate...Date.distantFuture,
                    isPresented: $showEndDatePicker
                )
                .zIndex(999)
            }
        }
        .background(
            (colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
            .ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: { dismiss() }) {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color("GreenButton"))
                Text("Back")
                    .foregroundColor(Color("GreenButton"))
            }
        })
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Goal"),
                message: Text("Are you sure you want to delete this goal?"),
                primaryButton: .destructive(Text("Delete")) {
                    deleteGoal()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // MARK: - Helpers
    
    private func updateProgress() {
        localGoal.progress = Int(
            (Double(localGoal.currentValue) / Double(localGoal.targetValue)) * 100
        )
    }
    
    private func saveGoal() {
        viewModel.updateGoal(localGoal)
        dismiss()
    }
    
    private func deleteGoal() {
        viewModel.deleteGoal(localGoal)
        dismiss()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
