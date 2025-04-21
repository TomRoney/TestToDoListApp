//
//  HomeView.swift
//  TestToDoList
//
//  Created by Tom Roney on 24/08/2024.
//

import SwiftUI
import FirebaseFirestore

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = HomeViewViewModel()
    @StateObject var goalsViewModel: GoalsViewModel
    @StateObject var debriefViewModel: DebriefViewViewModel
    @StateObject var intentionViewModel: IntentionViewViewModel
    @StateObject var exerciseViewModel: ExerciseViewViewModel
    @StateObject var sleepViewModel: SleepViewViewModel
    @State private var selectedDate = Date()
    @State private var newItemPresented = false
    @State private var profileImageUpdateTimestamp = Date()
    
    // Computed property to build the profile image URL.
    private var computedProfileImageURL: URL? {
        guard let profilePictureURL = viewModel.profilePictureURL else { return nil }
        let timestamp = Int(profileImageUpdateTimestamp.timeIntervalSince1970)
        let urlString = profilePictureURL + "?t=\(timestamp)"
        return URL(string: urlString)
    }
    
    // Computed property to combine intentions for the preview tile.
    private var previewIntentions: [Intention] {
        Array((intentionViewModel.intentions + intentionViewModel.completedIntentions).prefix(4))
    }
    
    init(userId: String) {
        _goalsViewModel = StateObject(wrappedValue: GoalsViewModel(userId: userId))
        _debriefViewModel = StateObject(wrappedValue: DebriefViewViewModel(currentUserId: userId, selectedDate: Date(), isPremiumUser: false))
        _intentionViewModel = StateObject(wrappedValue: IntentionViewViewModel(userId: userId, subscriptionStatus: "basic"))
        _exerciseViewModel = StateObject(wrappedValue: ExerciseViewViewModel(userId: userId))
        _viewModel = StateObject(wrappedValue: HomeViewViewModel())
        _sleepViewModel = StateObject(wrappedValue: SleepViewViewModel(userId: userId, selectedDate: Date()))
    }
    
    var body: some View {
        ZStack {
            (colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                .ignoresSafeArea()
            
            if viewModel.isSignedIn, !viewModel.currentUserId.isEmpty {
                accountView
                    .onChange(of: viewModel.subscriptionStatus) { newStatus in
                        debriefViewModel.isPremiumUser = (newStatus == "premium")
                    }
            } else {
                LogInView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ProfileImageUpdated"))) { _ in
            profileImageUpdateTimestamp = Date()
            viewModel.fetchProfilePictureURL() // Ensure this is implemented in HomeViewViewModel.
        }
    }
    
    @ViewBuilder
    var accountView: some View {
        TabView {
            NavigationView {
                VStack(spacing: 5) {
                    VStack(spacing: 5) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 5) {
                                // Welcome texts.
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Welcome")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                    
                                    if let firstname = viewModel.userfirstname {
                                        Text(firstname + "!")
                                            .font(.largeTitle)
                                            .fontWeight(.bold)
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                    }
                                }
                                .padding(.leading, -18)
                                
                                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .labelsHidden()
                                    .onChange(of: selectedDate) { newDate in
                                        intentionViewModel.selectedDate = newDate
                                        intentionViewModel.fetchIntentions(for: newDate)
                                        debriefViewModel.fetchDebriefs(for: newDate)
                                        exerciseViewModel.selectedDate = newDate
                                        exerciseViewModel.fetchExercises(for: newDate)
                                        sleepViewModel.updateSelectedDate(newDate)
                                    }
                                    .padding(8)
                                    .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, -22)
                            }
                            .padding(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer()
                            
                            // Profile image.
                            if let url = computedProfileImageURL {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 110, height: 110)
                                        .clipShape(Circle())
                                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                } placeholder: {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 110, height: 110)
                                        .clipShape(Circle())
                                        .foregroundColor(.gray)
                                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                }
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 110, height: 110)
                                    .clipShape(Circle())
                                    .foregroundColor(.gray)
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                        }
                        .padding(.top, 10)
                        .padding(.horizontal)
                        
                        NavigationLink(destination: IntentionView(userId: viewModel.currentUserId, subscriptionStatus: viewModel.subscriptionStatus, selectedDate: $selectedDate, newItemPresented: $newItemPresented)) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Intentions")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(height: 40, alignment: .topLeading)
                                VStack(alignment: .leading, spacing: 5) {
                                    ForEach(previewIntentions, id: \.id) { intention in
                                        HStack {
                                            Image(systemName: intention.isDone ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(intention.isDone ? .white : .white.opacity(0.7))
                                            Text(intention.title)
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                            Spacer()
                                        }
                                    }
                                    if (intentionViewModel.intentions.count + intentionViewModel.completedIntentions.count) > 4 {
                                        HStack {
                                            Spacer()
                                            Text("...")
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .frame(height: 180)
                            .background(Color("GreenButton"))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 20)
                    }
                    
                    if viewModel.subscriptionStatus == "premium" {
                        premiumLayout
                    } else {
                        nonPremiumLayout
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
                .onAppear {
                    intentionViewModel.selectedDate = selectedDate
                    intentionViewModel.fetchIntentions(for: selectedDate)
                    debriefViewModel.fetchDebriefs(for: selectedDate)
                    exerciseViewModel.selectedDate = selectedDate
                    exerciseViewModel.fetchExercises(for: selectedDate)
                    sleepViewModel.updateSelectedDate(selectedDate)
                }
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            
            // Updated call: passing subscriptionStatus to GoalsView.
            GoalsView(viewModel: goalsViewModel, subscriptionStatus: viewModel.subscriptionStatus)
                .tabItem {
                    Label("Goals", systemImage: "checkmark.seal.text.page")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
        .accentColor(Color("GreenButton"))
    }
    
    @ViewBuilder
    var premiumLayout: some View {
        HStack(spacing: 20) {
            VStack(spacing: 20) {
                NavigationLink(destination: SleepView(viewModel: sleepViewModel, selectedDate: selectedDate)) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Sleep")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 40)
                        if let sleepItem = sleepViewModel.filteredItems.first {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("\(sleepItem.hours) hours")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                Text(sleepItem.title)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                            }
                        } else {
                            Text("")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .frame(height: 150)
                    .background(Color("GreenButton"))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                
                NavigationLink(destination: ExerciseView(userId: viewModel.currentUserId, selectedDate: $selectedDate, newItemPresented: $newItemPresented)) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Exercise")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(height: 40, alignment: .topLeading)
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(exerciseViewModel.exercises.prefix(2), id: \.id) { exercise in
                                HStack {
                                    Image(systemName: exercise.isDone ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(exercise.isDone ? .white : .gray)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(exercise.title)
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.leading)
                                        Text(exercise.exerciseType)
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                            }
                            if exerciseViewModel.exercises.count > 2 {
                                HStack {
                                    Spacer()
                                    Text("...")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .frame(height: 180)
                    .background(Color("GreenButton"))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
            }
            .frame(maxWidth: .infinity)
            
            NavigationLink(destination: DebriefView(viewModel: debriefViewModel)) {
                debriefTile
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
    
    @ViewBuilder
    var nonPremiumLayout: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Advertisement")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .frame(height: 345)
            .background(colorScheme == .dark ? Color.black : Color(UIColor(white: 0.95, alpha: 1.0)))
            .cornerRadius(10)
            
            NavigationLink(destination: DebriefView(viewModel: debriefViewModel)) {
                debriefTile
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
    
    @ViewBuilder
    var debriefTile: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Debrief")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .frame(height: 40, alignment: .topLeading)
            Text(debriefViewModel.attributedDebrief.string.isEmpty ? "" : debriefViewModel.attributedDebrief.string)
                .font(.subheadline)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(15)
                .truncationMode(.tail)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .frame(height: 345)
        .background(Color("GreenButton"))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}
