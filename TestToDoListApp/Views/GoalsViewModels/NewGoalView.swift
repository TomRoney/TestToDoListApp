//
//  NewGoalView.swift
//  TestToDoList
//
//  Created by Tom Roney on 27/09/2024.
//

import SwiftUI
import Combine

#if canImport(UIKit)
extension View {
    /// Dismisses the keyboard for the current view.
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct NewGoalView: View {
    @ObservedObject var viewModel: GoalsViewModel
    @State private var title: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var goalType: String? = nil
    @State private var keyActions: [GoalKeyAction] = []
    @State private var currentValue: Int = 0
    @State private var targetValue: Int = 100

    @Environment(\.dismiss) var dismiss
    @State private var showError: Bool = false
    @State private var showKeyActionError: Bool = false

    // Inline date pickers
    @State private var showStartDatePicker = false
    @State private var showEndDatePicker = false

    @Environment(\.colorScheme) var colorScheme

    // Track the keyboard height to reposition the view
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("New Goal")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding(.bottom, 8)

                    // Goal Title
                    TextField("What do you want to achieve?", text: $title)
                        .padding()
                        .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("GreenButton"), lineWidth: 1)
                        )

                    // Error if empty title
                    if showError && title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("Title is required.")
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.leading, 5)
                    }

                    // Start Date
                    Button(action: { showStartDatePicker = true }) {
                        HStack {
                            Text("Start Date: \(formattedDate(startDate))")
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

                    // End Date
                    Button(action: { showEndDatePicker = true }) {
                        HStack {
                            Text("Due Date: \(formattedDate(endDate))")
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

                    if endDate < startDate {
                        Text("Please select a date in advance of the selected Start Date")
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.leading, 5)
                    }

                    // Goal Type
                    Menu {
                        Picker(selection: Binding<String>(
                            get: { goalType ?? "Type" },
                            set: { goalType = $0 == "Type" ? nil : $0 }
                        ), label: EmptyView()) {
                            Text("Personal").tag("Personal")
                            Text("Professional").tag("Professional")
                        }
                    } label: {
                        HStack {
                            Text(goalType ?? "Type")
                                .foregroundColor(goalType == nil ? Color.gray : (colorScheme == .dark ? .white : .black))
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
                    KeyActionSection(keyActions: $keyActions)

                    // Key Actions Error Message – only if a key action was added with empty text.
                    if showKeyActionError && keyActions.contains(where: { $0.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                        Text("Please fill in all key action fields or remove empty key actions.")
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.leading, 5)
                    }

                    // Progress Section
                    VStack(alignment: .leading) {
                        Text("Progress")
                            .font(.headline)
                            .padding(.top)
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Current")
                                Picker(selection: $currentValue, label: Text("\(currentValue)")
                                    .foregroundColor(Color("GreenButton"))) {
                                    ForEach(0...100, id: \.self) { value in
                                        Text("\(value)")
                                            .foregroundColor(Color("GreenButton"))
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .accentColor(Color("GreenButton"))
                                .frame(width: 100, height: 40)
                                .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color("GreenButton"), lineWidth: 1)
                                )
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("Target")
                                Picker(selection: $targetValue, label: Text("\(targetValue)")
                                    .foregroundColor(Color("GreenButton"))) {
                                    ForEach(0...100, id: \.self) { value in
                                        Text("\(value)")
                                            .foregroundColor(Color("GreenButton"))
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .accentColor(Color("GreenButton"))
                                .frame(width: 100, height: 40)
                                .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color("GreenButton"), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.vertical)
                    }

                    // Create Button
                    Button(action: {
                        // Reset error states
                        showError = false
                        showKeyActionError = false

                        // Validate title
                        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            showError = true
                        }
                        // Validate key actions only if any have been added
                        if !keyActions.isEmpty && keyActions.contains(where: { $0.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                            showKeyActionError = true
                        }

                        // If any error, return without creating goal
                        if showError || showKeyActionError {
                            return
                        }

                        let newGoal = UserGoal(
                            id: nil,
                            title: title,
                            startDate: startDate,
                            endDate: endDate,
                            progress: currentValue,
                            currentValue: currentValue,
                            targetValue: targetValue,
                            keyActions: keyActions,
                            goalType: goalType
                        )
                        viewModel.addGoal(newGoal)
                        dismiss()
                    }) {
                        Text("Create Goal")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                (title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                                 (!keyActions.isEmpty && keyActions.contains(where: { $0.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }))
                                ) ? Color.gray : Color("GreenButton")
                            )
                            .cornerRadius(10)
                    }
                    .padding(.top)
                    .disabled(
                        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        (!keyActions.isEmpty && keyActions.contains(where: { $0.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }))
                    )
                }
                .padding()
                // Adjust bottom padding based on the keyboard height so that the view moves up
                .padding(.bottom, keyboardHeight)
            }
            // Tap anywhere inside the scroll view to dismiss the keyboard.
            .onTapGesture {
                self.hideKeyboard()
            }

            // Inline Overlays for Start/End Date
            if showStartDatePicker {
                InlineDatePickerOverlay(
                    date: $startDate,
                    label: "Start Date",
                    isPresented: $showStartDatePicker
                )
                .zIndex(999)
            }
            if showEndDatePicker {
                InlineDatePickerOverlay(
                    date: $endDate,
                    label: "Due Date",
                    dateRange: startDate...Date.distantFuture,
                    isPresented: $showEndDatePicker
                )
                .zIndex(999)
            }
        }
        .clipped(antialiased: false)
        .background((colorScheme == .dark ? Color.black : Color("BackgroundBeige")).ignoresSafeArea())
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: { dismiss() }) {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Text("Back")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
        })
        // Listen for keyboard notifications to update the keyboard height
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation {
                    self.keyboardHeight = keyboardFrame.height
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation {
                self.keyboardHeight = 0
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
