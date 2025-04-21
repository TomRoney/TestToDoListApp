//
//  GoalSharedComponentsView.swift
//  TestToDoList
//
//  Created by Tom Roney on 28/02/2025.
//

import SwiftUI

struct KeyActionSection: View {
    @Binding var keyActions: [GoalKeyAction]
    /// Optional callback so that, for example, in EditGoalView a DB update can be triggered on toggle.
    var onToggle: (() -> Void)? = nil

    @Environment(\.colorScheme) var colorScheme

    // Estimated row height for each key action row.
    private var rowHeight: CGFloat { 60 }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: "Key Actions" title and the + button.
            HStack {
                Text("Key Actions")
                    .font(.headline)
                Spacer()
                Button(action: {
                    keyActions.append(
                        GoalKeyAction(
                            id: UUID(),
                            description: "",
                            actionType: "Percentage",
                            currentValue: 0,
                            targetValue: 100,
                            isCompleted: false
                        )
                    )
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color("GreenButton"))
                }
            }
            .padding(.top, 8)
            
            // List for key actions with swipe-to-delete; scrolling disabled so the entire view scrolls.
            List {
                ForEach($keyActions, id: \.id) { $keyAction in
                    HStack(spacing: 8) {
                        // Toggle checkmark (checkbox) aligned flush with the left edge.
                        Button(action: {
                            keyAction.isCompleted.toggle()
                            onToggle?()
                        }) {
                            Image(systemName: keyAction.isCompleted ? "checkmark.circle.fill" : "circle")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(keyAction.isCompleted ? Color("GreenButton") : .gray)
                        }
                        .buttonStyle(.plain)
                        
                        // Multiline TextField (iOS 16+) that wraps long text onto additional lines.
                        TextField("Key Action", text: $keyAction.description, axis: .vertical)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.system(size: 16))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    // Remove extra horizontal padding so the row starts flush with the title.
                    .padding(.horizontal, 0)
                    // Set the row background based on the current color scheme.
                    .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                    .cornerRadius(8)
                    // Remove the default list row insets so everything is aligned flush left.
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    // Hide the default separator.
                    .listRowSeparator(.hidden)
                    // Enable swipe-to-delete functionality.
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            if let index = keyActions.firstIndex(where: { $0.id == keyAction.id }) {
                                keyActions.remove(at: index)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    // Update the list row background based on the current color scheme.
                    .listRowBackground(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                }
            }
            .listStyle(PlainListStyle())
            .scrollDisabled(true) // Disable List's own scrolling.
            // Dynamically set the List's height so it expands with the number of key actions.
            .frame(height: max(CGFloat(keyActions.count) * rowHeight, 80))
        }
        // Remove any horizontal padding so the "Key Actions" header and its rows start at the screen edge.
        .padding(.horizontal, 0)
        .padding(.bottom, 0)
    }
}

struct ProgressSection: View {
    @Binding var currentValue: Int
    @Binding var targetValue: Int
    var onProgressChange: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text("Progress")
                .font(.headline)
                .padding(.top)
            HStack {
                PickerView(label: "Current", value: $currentValue, range: 0...targetValue, onChange: onProgressChange)
                Spacer()
                PickerView(label: "Target", value: $targetValue, range: 1...100, onChange: onProgressChange)
            }
            .padding(.vertical)
        }
    }
}

struct PickerView: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    var onChange: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
            Picker(selection: Binding(get: { value }, set: { newValue in
                value = newValue
                onChange()
            }), label: Text("\(value)")
                .foregroundColor(Color("GreenButton"))) {
                ForEach(range, id: \.self) { num in
                    Text("\(num)")
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
}

/**
 InlineDatePickerOverlay:
 - Presents a graphical DatePicker over a transparent background.
 - If the user taps outside the calendar, it closes.
 - If the user selects the same date OR a new date, it also closes.
 */
struct InlineDatePickerOverlay: View {
    @Binding var date: Date
    var label: String
    var dateRange: ClosedRange<Date>? = nil
    @Binding var isPresented: Bool

    // We keep a local selection so we can detect any tap in the calendar,
    // even if it picks the same date as already selected.
    @State private var localSelection: Date

    @Environment(\.colorScheme) var colorScheme

    init(date: Binding<Date>, label: String, dateRange: ClosedRange<Date>? = nil, isPresented: Binding<Bool>) {
        _date = date
        self.label = label
        self.dateRange = dateRange
        _isPresented = isPresented
        // Initialize localSelection to the current date
        _localSelection = State(initialValue: date.wrappedValue)
    }

    var body: some View {
        // Full-screen ZStack so user can tap outside to dismiss
        ZStack {
            // Transparent background
            Color.clear
                .onTapGesture {
                    // Close if user taps outside
                    isPresented = false
                }

            // The actual date picker
            VStack {
                DatePicker(
                    label,
                    selection: $localSelection,
                    in: dateRange ?? Date.distantPast...Date.distantFuture,
                    displayedComponents: .date
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .accentColor(Color("GreenButton"))
                .padding()
                .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                .cornerRadius(10)
            }
            .frame(maxWidth: 300)
            .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
            .cornerRadius(10)
            .shadow(radius: 10)
        }
        // Whenever localSelection changes, close the overlay.
        .onChange(of: localSelection) { newValue in
            if newValue == date {
                isPresented = false
            } else {
                date = newValue
                isPresented = false
            }
        }
    }
}
