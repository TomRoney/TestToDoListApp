//
//  GoalsView.swift
//  TestToDoList
//
//  Created by Tom Roney on 27/09/2024.
//

import SwiftUI

struct GoalsView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: GoalsViewModel
    var subscriptionStatus: String  // Should be "basic" or "premium"
    
    @State private var newGoalPresented: Bool = false
    @State private var showLimitAlert: Bool = false
    @State private var navigateToSubscription: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                    .ignoresSafeArea()
                
                VStack {
                    Text("Goals")
                        .font(.system(size: 34, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 40)
                        .padding(.bottom, 30)
                    
                    if viewModel.goals.isEmpty {
                        Spacer()
                        Text("")
                            .foregroundColor(.gray)
                            .padding()
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(viewModel.goals) { goal in
                                    NavigationLink(
                                        destination: GoalDetailView(viewModel: viewModel, goal: goal),
                                        label: {
                                            GoalRow(goal: goal)
                                        }
                                    )
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if subscriptionStatus == "basic" {
                            let currentYear = Calendar.current.component(.year, from: Date())
                            let yearCount = viewModel.goals.filter { goal in
                                let goalYear = Calendar.current.component(.year, from: goal.startDate)
                                return goalYear == currentYear
                            }.count
                            
                            if yearCount >= 4 {
                                showLimitAlert = true
                                return
                            }
                        }
                        newGoalPresented = true
                    }) {
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .foregroundColor(.greenButton)
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: "plus")
                                    .resizable()
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                            }
                            Text("Goal")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
                    .padding(.bottom, 30)
                    .sheet(isPresented: $newGoalPresented) {
                        NewGoalView(viewModel: viewModel)
                    }
                    
                    // NavigationLink to SubscriptionView without hiding the back button.
                    NavigationLink(destination: SubscriptionView(), isActive: $navigateToSubscription) {
                        EmptyView()
                    }
                    .hidden()
                }
            }
            .navigationBarHidden(true)
        }
        .alert(isPresented: $showLimitAlert) {
            Alert(
                title: Text("Goal Limited Reached"),
                message: Text("As an essential user, you can only create up to four Goals per year."),
                primaryButton: .default(Text("Upgrade"), action: {
                    navigateToSubscription = true
                }),
                secondaryButton: .default(Text("OK"))
            )
        }
    }
}

struct GoalDetailView: View {
    @ObservedObject var viewModel: GoalsViewModel
    @State private var goal: UserGoal  // Local state for editing

    init(viewModel: GoalsViewModel, goal: UserGoal) {
        self.viewModel = viewModel
        self._goal = State(initialValue: goal)
    }

    var body: some View {
        EditGoalView(viewModel: viewModel, goal: goal)
    }
}

struct GoalRow: View {
    let goal: UserGoal

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text("\(goal.startDate, formatter: dateFormatter) - \(goal.endDate, formatter: dateFormatter)")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text("\(goal.progress)%")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
        }
        .padding()
        .background(Color("GreenButton"))
        .cornerRadius(10)
        .padding(.horizontal)
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}
