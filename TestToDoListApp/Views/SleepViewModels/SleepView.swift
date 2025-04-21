//
//  SleepView.swift
//  TestToDoList
//
//  Created by Tom Roney on 27/08/2024.
//

import SwiftUI
import FirebaseFirestore

struct SleepView: View {
    @Environment(\.colorScheme) var colorScheme  // Detect the current color scheme
    @ObservedObject var viewModel: SleepViewViewModel
    let selectedDate: Date

    // Now SleepView accepts the shared viewModel instance.
    init(viewModel: SleepViewViewModel, selectedDate: Date) {
        self.viewModel = viewModel
        self.selectedDate = selectedDate
    }

    var body: some View {
        NavigationView {
            VStack {
                // Title
                HStack {
                    Text("How did you sleep last night?")
                        .font(.system(size: 28, weight: .bold))
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)

                // List of Sleep Entries (filtered by selected date)
                if viewModel.filteredItems.isEmpty {
                    Spacer()
                    Text("")
                        .foregroundColor(.gray)
                    Spacer()
                    addButton
                } else {
                    List {
                        ForEach(viewModel.filteredItems) { item in
                            SleepRowView(item: item, viewModel: viewModel)
                                .swipeActions {
                                    Button("Delete") {
                                        viewModel.delete(id: item.id)
                                    }
                                    .tint(.red)
                                }
                                // Change the row background based on the color scheme.
                                .listRowBackground(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden) // Removes the default white background.
                }
            }
            // Change the overall background based on the color scheme.
            .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
            // Present NewSleepView via the viewModel’s newItemPresented flag.
            .sheet(isPresented: $viewModel.newItemPresented) {
                NewSleepView(newItemPresented: $viewModel.newItemPresented, selectedDate: selectedDate)
            }
            .onAppear {
                viewModel.updateSelectedDate(selectedDate)
            }
        }
    }

    private var addButton: some View {
        Button(action: {
            viewModel.newItemPresented = true
        }) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .foregroundColor(Color("GreenButton"))
                        .frame(width: 60, height: 60)
                    Image(systemName: "plus")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                }
                Text("Sleep")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
        }
        .padding(.bottom, 30)
    }
}

struct SleepRowView: View {
    let item: Sleep
    @ObservedObject var viewModel: SleepViewViewModel
    @Environment(\.colorScheme) var colorScheme  // Detect the current color scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hours: \(item.hours)")
                .font(.subheadline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .bold()
            Text(item.title)
                .font(.subheadline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .fontWeight(.regular)
            if item.isDone {
                Text("Completed")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
    }
}
