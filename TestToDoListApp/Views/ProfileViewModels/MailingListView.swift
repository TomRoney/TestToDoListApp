//
//  MailingListView.swift
//  TestToDoList
//
//  Created by Tom Roney on 16/01/2025.
//

import SwiftUI

struct MailingListPopupView: View {
    @ObservedObject var viewModel: PreferencesViewViewModel
    @Environment(\.colorScheme) var colorScheme  // Check the system color scheme

    var body: some View {
        VStack(spacing: 12) {
            // Top row: Title on the left, X button on the right
            HStack {
                Text("Want to hear from us?")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: {
                    viewModel.showMailingListPopup = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            }

            // Mailing List toggle
            Toggle("Mailing List", isOn: $viewModel.isSubscribedToMailingList)
                .padding(.top, 8)

            // Save button (full width)
            Button(action: {
                viewModel.updateMailingListPreference()
                viewModel.showMailingListPopup = false
            }) {
                Text("Save")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color("GreenButton"))
                    .cornerRadius(10)
            }
            .padding(.top, 8)
        }
        // Outer padding around the entire modal
        .padding()
        // Constrain only the width so the modal isn’t too wide
        .frame(width: 300)
        // Change background based on dark/light mode
        .background(colorScheme == .dark ? Color.black : Color("BackgroundBeige"))
        .cornerRadius(10)
    }
}
