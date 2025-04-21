//
//  ManageSubscriptionView.swift
//  TestToDoList
//
//  Created by Tom Roney on 27/10/2024.
//

import SwiftUI
import StoreKit

struct ManageSubscriptionView: View {
    @ObservedObject var viewModel: SubscriptionViewViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Manage Subscription")
                .font(.largeTitle).bold()

            if viewModel.products.isEmpty {
                ProgressView("Loading Plans…")
            } else {
                ForEach(viewModel.products, id: \.id) { product in
                    VStack(spacing: 10) {
                        Text(product.displayName)
                            .font(.title2).bold()
                        Text(product.description)
                            .font(.subheadline)

                        Button {
                            Task {
                                await viewModel.purchase(product: product)
                            }
                        } label: {
                            Text(product.displayPrice)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("GreenButton"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color("BackgroundBeige"))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
            }

            Spacer()

            if viewModel.isPremiumUser {
                Button("Manage in App Store") {
                    if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.footnote)
                .foregroundColor(.blue)
                .padding(.top)
            }
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
}
