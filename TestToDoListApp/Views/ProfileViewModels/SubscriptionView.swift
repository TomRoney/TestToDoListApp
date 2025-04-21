//
//  SubscriptionView.swift
//  TestToDoList
//
//  Created by Tom Roney on 07/10/2024.
//

import SwiftUI

struct SubscriptionView: View {
    @StateObject var viewModel = SubscriptionViewViewModel()
    @State private var profileImageUpdateTimestamp = Date()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Subscription")
                    .font(.largeTitle)
                    .bold()
                    .padding(.leading)
                Spacer()
                profileImageSection()
                    .padding(.trailing)
            }
            .padding(.top)

            Spacer(minLength: 30)

            VStack {
                subscriptionDetailsSection()
                Spacer()
                manageSubscriptionButton()
            }
            .padding()

            Spacer()
        }
        .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        // Kick off all async loading here:
        .task {
            await viewModel.loadAllData()
        }
        .onReceive(
            NotificationCenter.default.publisher(for: Notification.Name("ProfileImageUpdated"))
        ) { _ in
            profileImageUpdateTimestamp = Date()
            Task { await viewModel.fetchProfileImage() }
        }
    }

    private func profileImageSection() -> some View {
        VStack {
            if let img = viewModel.profileImage {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 110, height: 110)
                    .clipShape(Circle())
                    .shadow(radius: 4)
                    .id(profileImageUpdateTimestamp)
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 110, height: 110)
                    .foregroundColor(.gray)
                    .shadow(radius: 4)
            }
        }
    }

    private func subscriptionDetailsSection() -> some View {
        VStack(spacing: 20) {
            HStack {
                Text("Products")
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color("GreenText"))
                    .frame(maxWidth: .infinity)
                Text("Essential")
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color("GreenText"))
                    .frame(maxWidth: .infinity)
                Text("Premium")
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color("GreenText"))
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)

            Divider()

            VStack(spacing: 10) {
                subscriptionRow(product: "Intentions", basics: "4 Daily", premium: "Unlimited")
                subscriptionRow(product: "Debrief",    basics: "150 words", premium: "300 words")
                subscriptionRow(product: "Goals",      basics: "4 Yearly", premium: "Unlimited")
                subscriptionRow(product: "Exercise",   basics: "✖️", premium: "Unlimited")
                subscriptionRow(product: "Sleep",      basics: "✖️", premium: "Unlimited")
                subscriptionRow(product: "Adverts",    basics: "✔️", premium: "✖️")
                Divider()
                subscriptionRow(product: "", basics: "Free", premium: "£4.99 p/m")
            }
            .padding(.horizontal)
        }
        .padding(.top, 20)
    }

    private func subscriptionRow(product: String, basics: String, premium: String) -> some View {
        HStack {
            Text(product)
                .foregroundColor(Color("GreenText"))
                .frame(maxWidth: .infinity)

            cell(for: basics)
            cell(for: premium)
        }
        .padding(.vertical, 5)
    }

    private func cell(for value: String) -> some View {
        Group {
            switch value {
            case "✔️": Image(systemName: "checkmark")
            case "✖️": Image(systemName: "xmark")
            default:    Text(value)
            }
        }
        .foregroundColor(Color("GreenText"))
        .frame(maxWidth: .infinity)
    }

    private func manageSubscriptionButton() -> some View {
        VStack {
            NavigationLink(destination: ManageSubscriptionView(viewModel: viewModel)) {
                Text("Manage Subscription")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("GreenButton"))
                    .cornerRadius(10)
            }
            .padding()

            Text(viewModel.isPremiumUser
                 ? "You are on the Premium plan"
                 : "You are on the Essential plan")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.bottom, 10)
        }
        .padding(.top)
    }
}
