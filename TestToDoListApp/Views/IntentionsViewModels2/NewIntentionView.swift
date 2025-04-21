//
//  NewIntentionView.swift
//  TestToDoList
//
//  Created by Tom Roney on 23/01/2025.
//

import SwiftUI

struct NewIntentionView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: NewIntentionViewViewModel
    @Binding var newItemPresented: Bool
    var selectedDate: Date
    
    @State private var showingTypePicker = false
    @State private var showingPriorityPicker = false
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Text("New Intention")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    .padding(.leading, 16)
                Spacer()
                Button(action: { newItemPresented = false }) {
                    Image(systemName: "xmark")
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .padding()
                }
            }
            .padding(.top, 16)
            
            // Form Fields
            VStack(spacing: 16) {
                
                // Intention Title - using TextEditor for multi-line wrapping
                ZStack(alignment: .topLeading) {
                    if viewModel.title.isEmpty {
                        Text("Intention Title")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 12)
                    }
                    TextEditor(text: $viewModel.title)
                        .padding(8)
                        .frame(height: 80)
                        .scrollContentBackground(.hidden)
                        .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("GreenButton"), lineWidth: 2)
                        )
                }
                .padding(.horizontal, 16)
                
                // Intention Type Menu
                Menu {
                    ForEach(["Personal", "Professional"], id: \.self) { type in
                        Button {
                            viewModel.intentionType = type
                        } label: {
                            Text(type)
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        }
                    }
                } label: {
                    HStack {
                        Text("Intention Type")
                            .font(.body)
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        Spacer()
                        Text(viewModel.intentionType ?? "")
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        Image(systemName: "chevron.down")
                            .foregroundColor(Color("GreenButton"))
                    }
                    .padding()
                    .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("GreenButton"), lineWidth: 2)
                    )
                    .padding(.horizontal, 16)
                }
                
                // Priority Menu (only "High", "Medium", "Low")
                Menu {
                    ForEach(["High", "Medium", "Low"], id: \.self) { priority in
                        Button {
                            viewModel.priority = priority
                        } label: {
                            Text(priority)
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        }
                    }
                } label: {
                    HStack {
                        Text("Priority")
                            .font(.body)
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        Spacer()
                        Text(viewModel.priority ?? "")
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        Image(systemName: "chevron.down")
                            .foregroundColor(Color("GreenButton"))
                    }
                    .padding()
                    .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("GreenButton"), lineWidth: 2)
                    )
                    .padding(.horizontal, 16)
                }
                
                Spacer()
            }
            .padding(.top, 16)
            
            // Save Button
            Button(action: {
                // If no priority was selected, force priority to be an empty string
                if viewModel.priority == nil {
                    viewModel.priority = ""
                }
                viewModel.saveIntention(for: selectedDate)
                newItemPresented = false
            }) {
                Text("Save Intention")
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
        .padding(.top, 16)
        .background((colorScheme == .dark ? Color.black : Color("BackgroundBeige")).ignoresSafeArea())
        .onAppear {
            // Clear any default priority so that if the user doesn't tap the menu,
            // the priority remains nil and later is set to "" on save.
            viewModel.priority = nil
        }
    }
    
    // The custom picker sections remain unchanged.
    struct IntentionPickerSection: View {
        var title: String
        var value: String
        var onTap: () -> Void
        
        var body: some View {
            VStack {
                HStack {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.black)
                        .padding(.leading, 12)
                    Spacer()
                    Text(value)
                        .foregroundColor(.primary)
                        .padding(.trailing, 12)
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color("GreenButton"))
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .onTapGesture {
                    onTap()
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    struct CustomIntentionTypePicker: View {
        @Binding var selectedType: String?
        @Binding var showingPicker: Bool
        
        let allTypes = [
            "Personal", "Professional"
        ]
        
        var body: some View {
            NavigationView {
                List {
                    Section(header: Text("All Types")) {
                        ForEach(allTypes, id: \.self) { type in
                            SelectableIntentionRow(type: type)
                                .onTapGesture {
                                    selectedType = type
                                    showingPicker = false
                                }
                        }
                    }
                }
                .navigationTitle("Intention Type")
                .navigationBarItems(leading: Button("Cancel") {
                    showingPicker = false
                })
            }
        }
    }
    
    struct CustomPriorityPicker: View {
        @Binding var selectedPriority: String?
        @Binding var showingPicker: Bool
        
        let allPriorities = [
            "High", "Medium", "Low"
        ]
        
        var body: some View {
            NavigationView {
                List {
                    Section(header: Text("All Priorities")) {
                        ForEach(allPriorities, id: \.self) { priority in
                            SelectablePriorityRow(priority: priority)
                                .onTapGesture {
                                    selectedPriority = priority
                                    showingPicker = false
                                }
                        }
                    }
                }
                .navigationTitle("Priority")
                .navigationBarItems(leading: Button("Cancel") {
                    showingPicker = false
                })
            }
        }
    }
    
    struct SelectablePriorityRow: View {
        var priority: String
        
        var body: some View {
            HStack {
                Text(priority)
                    .foregroundColor(.primary)
                Spacer()
            }
        }
    }
    
    struct SelectableIntentionRow: View {
        var type: String
        
        var body: some View {
            HStack {
                Text(type)
                    .foregroundColor(.primary)
                Spacer()
            }
        }
    }
}
