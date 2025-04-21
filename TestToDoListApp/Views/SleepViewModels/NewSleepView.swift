//
//  NewSleepView.swift
//  TestToDoList
//
//  Created by Tom Roney on 29/08/2024.
//

import SwiftUI

struct NewSleepView: View {
    @Environment(\.colorScheme) var colorScheme  // Detect the current color scheme
    @StateObject var viewModel = NewSleepViewViewModel()
    @Binding var newItemPresented: Bool
    let selectedDate: Date

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Add Sleep Record")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding(.leading, 0)
                    Spacer()
                }
                .padding(.top, -40)
                
                // Hours input field changed from Picker to free-text input
                VStack(alignment: .leading, spacing: 5) {
                    Text("Hours")
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    TextField("Enter hours", text: $viewModel.selectedHours)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("GreenButton"), lineWidth: 1)
                        )
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("How did you sleep last night?")
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    ZStack(alignment: .topLeading) {
                        if viewModel.title.isEmpty {
                            Text("How did you sleep last night?")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 8)
                                .padding(.top, 12)
                        }
                        TextEditor(text: $viewModel.title)
                            .padding(8)
                            .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                            .cornerRadius(8)
                            .frame(height: 150) // Increased height to fit 5 rows of text
                            .scrollContentBackground(.hidden)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("GreenButton"), lineWidth: 1)
                            )
                    }
                }
                .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))

                Spacer()

                Button(action: {
                    if viewModel.canSave {
                        // Ensure that the new Sleep item uses selectedDate as its creation date.
                        viewModel.save(for: selectedDate)
                        newItemPresented = false
                    } else {
                        viewModel.showAlert = true
                    }
                }) {
                    Text("Save Sleep")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("GreenButton"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.vertical, 10)
            }
            .padding()
            .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        newItemPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text("Please complete all fields before saving")
                )
            }
        }
        .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
    }
}

// Optional: Retained for future use if needed elsewhere.
struct PickerField: View {
    @Environment(\.colorScheme) var colorScheme  // Detect the current color scheme
    let title: String
    @Binding var selection: String
    let options: [String]
    let backgroundColor: Color
    let placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        selection = option
                    }
                }
            } label: {
                HStack {
                    Text(selection.isEmpty ? placeholder : selection)
                        .foregroundColor(selection.isEmpty ? .gray : (colorScheme == .dark ? .white : .black))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color("GreenButton"))
                }
                .padding()
                .background(backgroundColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color("GreenButton"), lineWidth: 1)
                )
            }
        }
    }
}
