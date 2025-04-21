//
//  ExerciseView.swift
//  TestToDoList
//
//  Created by Tom Roney on 27/08/2024.
//

import SwiftUI

struct ExerciseView: View {
    var userId: String
    @StateObject var viewModel: ExerciseViewViewModel
    @Binding var newItemPresented: Bool
    @Binding var selectedDate: Date  // Binding for selectedDate
    
    // Added to detect Dark Mode
    @Environment(\.colorScheme) var colorScheme
    
    // Computed property to set background color based on color scheme
    var backgroundColor: Color {
        colorScheme == .dark ? .black : Color("BackgroundBeige")
    }
    
    init(userId: String, selectedDate: Binding<Date>, newItemPresented: Binding<Bool>) {
        self.userId = userId
        self._viewModel = StateObject(wrappedValue: ExerciseViewViewModel(userId: userId))
        self._newItemPresented = newItemPresented
        self._selectedDate = selectedDate  // Initialize the Binding for selectedDate
    }
    
    var body: some View {
        // Do not wrap in an extra NavigationView.
        GeometryReader { geometry in
            VStack {
                HStack {
                    Text("Are you Exercising today?")
                        .font(.system(size: 28, weight: .bold))
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                if viewModel.exercises.isEmpty {
                    Spacer()
                    Text("")
                        .foregroundColor(.gray)
                } else {
                    List {
                        ForEach(viewModel.exercises) { exercise in
                            HStack {
                                Button(action: {
                                    toggleExerciseCompletion(exercise)
                                }) {
                                    Image(systemName: exercise.isDone ? "checkmark.circle.fill" : "circle")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(exercise.isDone ? Color("GreenButton") : .gray)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.leading, 10)
                                
                                VStack(alignment: .leading) {
                                    Text(exercise.title)
                                        .font(.system(size: 18, weight: .semibold))
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Type: \(exercise.exerciseType)")
                                            .font(.system(size: 14, weight: .regular))
                                        Text("Duration: \(exercise.duration) min")
                                            .font(.system(size: 14, weight: .regular))
                                    }
                                }
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.delete(id: exercise.id) { result in
                                        // Handle deletion result if needed
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .listRowBackground(backgroundColor)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(backgroundColor)
                }
                
                Spacer()
                
                // NavigationLink to push NewExerciseView onto the stack.
                NavigationLink(
                    destination: NewExerciseView(
                        viewModel: NewExerciseViewViewModel(userId: userId),
                        selectedDate: selectedDate  // Pass Date directly
                    )
                ) {
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
                        Text("Exercise")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                }
                .padding(.bottom, 30)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(backgroundColor)
            .onAppear {
                viewModel.fetchExercises(for: selectedDate) { result in
                    switch result {
                    case .success:
                        break
                    case .failure(let error):
                        print("Error fetching exercises: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func toggleExerciseCompletion(_ exercise: Exercise) {
        var updatedExercise = exercise
        
        if !updatedExercise.isDone {
            updatedExercise.isDone = true
            viewModel.moveExerciseToBottom(exercise: updatedExercise) {
                // Handle post-move actions if needed
            }
            viewModel.updateExercise(updatedExercise) { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    print("Error updating exercise: \(error.localizedDescription)")
                }
            }
        } else {
            updatedExercise.isDone = false
            viewModel.updateExercise(updatedExercise) { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    print("Error updating exercise: \(error.localizedDescription)")
                }
            }
        }
    }
}
