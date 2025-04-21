//
//  IntentionsView2.swift
//  TestToDoList
//
//  Created by Tom Roney on 23/01/2025.
//

import SwiftUI

struct IntentionView: View {
    @Environment(\.colorScheme) var colorScheme
    var userId: String
    var subscriptionStatus: String
    @StateObject var viewModel: IntentionViewViewModel
    @Binding var newItemPresented: Bool
    @Binding var selectedDate: Date  // Binding for selectedDate
    
    @State private var showLimitAlert = false  // To show an alert if the daily limit is reached
    @State private var navigateToSubscription = false // Triggers navigation to SubscriptionView

    // Update the initializer to accept subscriptionStatus and pass it to the view model.
    init(userId: String, subscriptionStatus: String, selectedDate: Binding<Date>, newItemPresented: Binding<Bool>) {
        self.userId = userId
        self.subscriptionStatus = subscriptionStatus
        self._viewModel = StateObject(wrappedValue: IntentionViewViewModel(userId: userId, subscriptionStatus: subscriptionStatus))
        self._newItemPresented = newItemPresented
        self._selectedDate = selectedDate  // Initialize the Binding for selectedDate
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    HStack {
                        Text("What are your Intentions today?")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    if viewModel.intentions.isEmpty && viewModel.completedIntentions.isEmpty {
                        Spacer()
                        Text("")
                            .foregroundColor(.gray)
                    } else {
                        List {
                            // Main list for active intentions
                            ForEach(viewModel.intentions) { intention in
                                HStack {
                                    Button(action: {
                                        toggleIntentionCompletion(intention)
                                    }) {
                                        Image(systemName: intention.isDone ? "checkmark.circle.fill" : "circle")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(intention.isDone ? Color("GreenButton") : .gray)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.leading, 10)
                                    
                                    VStack(alignment: .leading) {
                                        Text(intention.title)
                                            .font(.system(size: 18, weight: .semibold))
                                            .fixedSize(horizontal: false, vertical: true)
                                        
                                        if !intention.intentionType.isEmpty && intention.intentionType != "Unknown" {
                                            Text("Type: \(intention.intentionType)")
                                                .font(.system(size: 14, weight: .regular))
                                                .lineLimit(1)
                                        }
                                    }
                                    Spacer()
                                    
                                    // Displaying Priority based on the level.
                                    Text(priorityIndicator(for: intention.priority))
                                        .font(.system(size: 20, weight: .light))
                                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                        .padding(.trailing, 16)
                                }
                                .contentShape(Rectangle())
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        viewModel.delete(id: intention.id) { result in
                                            // Handle the result of delete
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .listRowBackground(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                                .listRowSeparator(.hidden)
                            }

                            // Section for completed intentions
                            if !viewModel.completedIntentions.isEmpty {
                                Section(header: Text("Completed:")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)) {
                                    ForEach(viewModel.completedIntentions) { intention in
                                        HStack {
                                            Button(action: {
                                                toggleIntentionCompletion(intention)
                                            }) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                    .foregroundColor(Color("GreenButton"))
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .padding(.leading, 10)
                                            
                                            VStack(alignment: .leading) {
                                                Text(intention.title)
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .fixedSize(horizontal: false, vertical: true)
                                                    .foregroundColor(.gray)
                                                
                                                if !intention.intentionType.isEmpty && intention.intentionType != "Unknown" {
                                                    Text("Type: \(intention.intentionType)")
                                                        .font(.system(size: 14, weight: .regular))
                                                        .lineLimit(1)
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                            Spacer()
                                            
                                            Text(priorityIndicator(for: intention.priority))
                                                .font(.system(size: 20, weight: .light))
                                                .foregroundColor(.gray)
                                                .padding(.trailing, 16)
                                        }
                                        .listRowBackground(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                                        .listRowSeparator(.hidden)
                                    }
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                        .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if subscriptionStatus == "basic" {
                            let calendar = Calendar.current
                            let todayCount = viewModel.allIntentions.filter { intention in
                                let intentionDate = Date(timeIntervalSince1970: intention.date)
                                return calendar.isDate(intentionDate, inSameDayAs: selectedDate)
                            }.count
                            
                            if todayCount >= 4 {
                                showLimitAlert = true
                                return
                            }
                        }
                        newItemPresented = true
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
                            Text("Intention")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        }
                    }
                    .padding(.bottom, 30)
                    .sheet(isPresented: $newItemPresented, onDismiss: {
                        // Fetch latest intentions when NewIntentionView is dismissed
                        viewModel.fetchIntentions(for: selectedDate) { result in
                            switch result {
                            case .success:
                                print("Intentions updated after dismissal")
                            case .failure(let error):
                                print("Error updating intentions: \(error.localizedDescription)")
                            }
                        }
                    }) {
                        NewIntentionView(
                            viewModel: NewIntentionViewViewModel(userId: userId),
                            newItemPresented: $newItemPresented,
                            selectedDate: selectedDate
                        )
                    }
                    
                    // Hidden NavigationLink to SubscriptionView for Upgrade action.
                    NavigationLink(destination: SubscriptionView().navigationBarBackButtonHidden(true), isActive: $navigateToSubscription) {
                        EmptyView()
                    }
                    .hidden()
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background((colorScheme == .dark ? Color.black : Color("BackgroundBeige")).ignoresSafeArea())
                .onAppear {
                    viewModel.fetchIntentions(for: selectedDate) { result in
                        switch result {
                        case .success:
                            print("Intentions fetched successfully: \(viewModel.intentions)")
                        case .failure(let error):
                            print("Error fetching intentions: \(error.localizedDescription)")
                        }
                    }
                }
                .alert(isPresented: $showLimitAlert) {
                    Alert(
                        title: Text("Daily Limit Reached"),
                        message: Text("As an essentials user, you can only create up to four Intentions per day."),
                        primaryButton: .default(Text("Upgrade"), action: {
                            navigateToSubscription = true
                        }),
                        secondaryButton: .default(Text("OK"))
                    )
                }
            }
        }
    }
    
    private func toggleIntentionCompletion(_ intention: Intention) {
        if let index = viewModel.allIntentions.firstIndex(where: { $0.id == intention.id }) {
            // Toggle the completion status
            viewModel.allIntentions[index].isDone.toggle()
            let updatedIntention = viewModel.allIntentions[index]
            
            if updatedIntention.isDone {
                viewModel.intentions.removeAll { $0.id == updatedIntention.id }
                viewModel.completedIntentions.append(updatedIntention)
            } else {
                viewModel.completedIntentions.removeAll { $0.id == updatedIntention.id }
                viewModel.intentions.append(updatedIntention)
            }
            
            viewModel.updateIntention(updatedIntention) { result in
                switch result {
                case .success:
                    print("Firestore updated successfully")
                case .failure(let error):
                    print("Error updating Firestore: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func priorityIndicator(for priority: String?) -> String {
        switch priority {
        case "High":
            return "!!!"
        case "Medium":
            return "!!"
        case "Low":
            return "!"
        default:
            return ""
        }
    }
}
