//
//  NewExerciseView.swift
//  TestToDoList
//
//  Created by Tom Roney on 29/08/2024.
//

import SwiftUI
import FirebaseFirestore

struct NewExerciseView: View {
    @StateObject var viewModel: NewExerciseViewViewModel
    var selectedDate: Date // Use Date instead of Binding<Date>
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    var backgroundColor: Color {
        colorScheme == .dark ? .black : Color("BackgroundBeige")
    }
    
    @State private var showingTypePicker = false
    @State private var showingDurationPicker = false

    // Load favourites from UserDefaults
    @State private var favourites: Set<String> = Set(UserDefaults.standard.stringArray(forKey: "favouriteExerciseTypes") ?? [])
    
    var body: some View {
        VStack {
            // -- Custom Title (large, left-aligned)
            HStack {
                Text("New Exercise")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            // -- Form Fields
            VStack(spacing: 16) {
                // Exercise Title
                TextField("Exercise Title", text: $viewModel.title)
                    .padding()
                    .background(backgroundColor)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("GreenButton"), lineWidth: 2)
                    )
                    .padding(.horizontal, 16)
                
                // Exercise Type Picker
                PickerSection(title: "Exercise Type", value: viewModel.exerciseType ?? "", backgroundColor: backgroundColor) {
                    showingTypePicker.toggle()
                }
                .sheet(isPresented: $showingTypePicker) {
                    CustomExerciseTypePicker(
                        selectedType: $viewModel.exerciseType,
                        favourites: $favourites,
                        showingPicker: $showingTypePicker
                    )
                }
                
                // Duration Picker
                PickerSection(title: "Duration", value: viewModel.duration == 0 ? "" : "\(viewModel.duration) mins", backgroundColor: backgroundColor) {
                    showingDurationPicker.toggle()
                }
                .sheet(isPresented: $showingDurationPicker) {
                    CustomDurationPicker(
                        selectedDuration: $viewModel.duration,
                        showingPicker: $showingDurationPicker,
                        backgroundColor: backgroundColor
                    )
                }
                
                Spacer()
            }
            .padding(.top, 16)
            
            // -- Save Button
            Button(action: {
                viewModel.saveExercise(for: selectedDate)
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save Exercise")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isFormValid ? Color("GreenButton") : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
            }
            .disabled(!viewModel.isFormValid)
            .padding(.top, 32)
            .padding(.bottom, 32)
        }
        // Make sure the nav bar is shown, no system title, and the back button is visible.
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(false)
        .background(backgroundColor)
    }
}

// MARK: - PickerSection

struct PickerSection: View {
    var title: String
    var value: String
    var backgroundColor: Color
    var onTap: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundColor(.gray)
                Spacer()
                Text(value)
                    .foregroundColor(.primary)
                Image(systemName: "chevron.down")
                    .foregroundColor(Color("GreenButton"))
            }
            .padding()
            .background(backgroundColor)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("GreenButton"), lineWidth: 2))
            .onTapGesture {
                onTap()
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - CustomExerciseTypePicker

struct CustomExerciseTypePicker: View {
    @Binding var selectedType: String?
    @Binding var favourites: Set<String>
    @Binding var showingPicker: Bool
    
    let allTypes = [
        "Strength Training", "Running", "Walking", "Swimming", "Cycling", "Triathlon",
        "Hiking", "Rowing", "Yoga", "Pilates", "Dance",
        "Football", "Basketball", "Tennis", "Paddle", "Rugby"
    ]
    
    @Environment(\.colorScheme) var colorScheme
    var backgroundColor: Color {
        colorScheme == .dark ? .black : Color("BackgroundBeige")
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom header
                HStack {
                    Text("Exercise Type")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.leading, 20)
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.bottom, 12)
                .background(backgroundColor)
                
                backgroundColor.frame(height: 10)
                
                List {
                    // Favourites Section
                    if !favourites.isEmpty {
                        Section(header: Text("Favourites")) {
                            ForEach(Array(favourites), id: \.self) { type in
                                SelectableExerciseRow(
                                    type: type,
                                    isFavourite: favourites.contains(type)
                                ) {
                                    toggleFavourite(for: type)
                                }
                                .onTapGesture {
                                    selectedType = type
                                    showingPicker = false
                                }
                                .listRowSeparatorTint(Color("GreenButton"))
                                .listRowBackground(backgroundColor)
                            }
                        }
                    }
                    
                    // All Exercise Types Section
                    Section(header: Text("All Types")) {
                        ForEach(allTypes, id: \.self) { type in
                            SelectableExerciseRow(
                                type: type,
                                isFavourite: favourites.contains(type)
                            ) {
                                toggleFavourite(for: type)
                            }
                            .onTapGesture {
                                selectedType = type
                                showingPicker = false
                            }
                            .listRowSeparatorTint(Color("GreenButton"))
                            .listRowBackground(backgroundColor)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .scrollContentBackground(.hidden)
                .background(backgroundColor)
            }
            .navigationBarHidden(true)
        }
    }
    
    private func toggleFavourite(for type: String) {
        if favourites.contains(type) {
            favourites.remove(type)
        } else {
            favourites.insert(type)
        }
        UserDefaults.standard.set(Array(favourites), forKey: "favouriteExerciseTypes")
    }
}

// MARK: - SelectableExerciseRow

struct SelectableExerciseRow: View {
    var type: String
    var isFavourite: Bool
    var onFavouriteTapped: () -> Void
    
    var body: some View {
        HStack {
            Text(type)
                .foregroundColor(.primary)
            Spacer()
            Button(action: onFavouriteTapped) {
                Image(systemName: isFavourite ? "star.fill" : "star")
                    .foregroundColor(Color("GreenButton"))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - CustomDurationPicker

struct CustomDurationPicker: View {
    @Binding var selectedDuration: Int
    @Binding var showingPicker: Bool

    @State private var customDurationText: String = ""

    let popularDurations = [30, 60, 90]
    let incrementalDurations = Array(stride(from: 5, through: 120, by: 5))
    
    var backgroundColor: Color

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom header with left-aligned "Duration" and right-aligned "Apply"
                HStack {
                    Text("Duration")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.primary)
                    Spacer()
                    Button("Apply") {
                        if let customValue = Int(customDurationText), customValue > 0 {
                            selectedDuration = customValue
                            showingPicker = false
                        }
                    }
                    .foregroundColor(Color("GreenText"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(backgroundColor)
                
                // The list of duration options
                List {
                    // Custom Duration Section with outlined input field and error message
                    Section(header: Text("Custom Duration")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                                .textCase(nil)
                    ) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                TextField("Add amount", text: $customDurationText)
                                    .keyboardType(.numberPad)
                                    .padding(8)
                                    .frame(maxWidth: .infinity)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color("GreenButton"), lineWidth: 2)
                                    )
                            }
                            // Show error message if non-numeric characters are entered.
                            if !customDurationText.isEmpty && !customDurationText.allSatisfy({ $0.isNumber }) {
                                Text("Please input numbers only to save your Exercise duration")
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(.horizontal, 4)
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(backgroundColor)
                    }
                    
                    // Common Durations Section
                    Section(header: Text("Common Durations")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                                .textCase(nil)
                    ) {
                        ForEach(popularDurations, id: \.self) { duration in
                            HStack {
                                Text("\(duration) mins")
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedDuration == duration {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedDuration = duration
                                showingPicker = false
                            }
                            .listRowSeparatorTint(Color("GreenButton"))
                            .listRowBackground(backgroundColor)
                        }
                    }
                    
                    // All Durations Section
                    Section(header: Text("All Durations")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                                .textCase(nil)
                    ) {
                        ForEach(incrementalDurations, id: \.self) { duration in
                            HStack {
                                Text("\(duration) mins")
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedDuration == duration {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedDuration = duration
                                showingPicker = false
                            }
                            .listRowSeparatorTint(Color("GreenButton"))
                            .listRowBackground(backgroundColor)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .scrollContentBackground(.hidden)
                .background(backgroundColor)
            }
            .navigationBarHidden(true)
        }
    }
}
