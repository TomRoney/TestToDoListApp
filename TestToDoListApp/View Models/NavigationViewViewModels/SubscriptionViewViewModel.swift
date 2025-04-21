//
//  SubscriptionViewViewModel.swift
//  TestToDoList
//
//  Created by Tom Roney on 08/09/2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import StoreKit

@MainActor
class SubscriptionViewViewModel: NSObject, ObservableObject {
    @Published var user: User?             = nil
    @Published var profileImage: UIImage?  = nil
    @Published var products: [Product]     = []
    @Published var isPremiumUser: Bool     = false

    private var transactionListener: Task<Void, Never>?

    override init() {
        super.init()
    }

    deinit {
        transactionListener?.cancel()
    }

    /// Call this from your SwiftUI view’s `.task` modifier
    func loadAllData() async {
        // 1) Start listening for StoreKit transactions (only once)
        if transactionListener == nil {
            transactionListener = Task(priority: .background) { [weak self] in
                guard let self = self else { return }
                for await verification in StoreKit.Transaction.updates {
                    do {
                        let txn = try self.checkVerified(verification)
                        await self.handleTransaction(
                            txn,
                            isPremium: txn.productID == "premium_subscription"
                        )
                    } catch {
                        print("⚠️ Transaction verification failed: \(error)")
                    }
                }
            }
        }

        // 2) Then load products, subscription status, and profile image
        await fetchProducts()
        await checkSubscriptionStatus()
        await fetchProfileImage()
    }

    // MARK: - StoreKit / Products

    func fetchProducts() async {
        do {
            let ids = ["free_subscription", "premium_subscription"]
            products = try await Product.products(for: ids)
        } catch {
            print("⚠️ Failed to fetch products: \(error.localizedDescription)")
        }
    }

    func purchase(product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                do {
                    let txn = try checkVerified(verification)
                    await handleTransaction(
                        txn,
                        isPremium: product.id == "premium_subscription"
                    )
                } catch {
                    print("⚠️ Unverified purchase: \(error)")
                }
            case .userCancelled:
                print("ℹ️ User cancelled purchase")
            case .pending:
                print("ℹ️ Purchase pending")
            @unknown default:
                print("⚠️ Unknown purchase state")
            }
        } catch {
            print("⚠️ Purchase error: \(error.localizedDescription)")
        }
    }

    private func handleTransaction(
        _ transaction: StoreKit.Transaction,
        isPremium: Bool
    ) async {
        await updateSubscriptionStatus(isPremium: isPremium)
        await transaction.finish()
    }

    private func checkVerified(
        _ verification: StoreKit.VerificationResult<StoreKit.Transaction>
    ) throws -> StoreKit.Transaction {
        switch verification {
        case .verified(let txn):
            return txn
        case .unverified(_, let err):
            throw err
        }
    }

    // MARK: - Subscription Status

    func checkSubscriptionStatus() async {
        // 1) Check StoreKit entitlements
        var hasPremium = false
        for await verification in StoreKit.Transaction.currentEntitlements {
            if case .verified(let txn) = verification,
               txn.productID == "premium_subscription" {
                hasPremium = true
                break
            }
        }

        if hasPremium {
            await updateSubscriptionStatus(isPremium: true)
        } else if let uid = Auth.auth().currentUser?.uid {
            // 2) Fallback to Firestore‑stored flag
            let db = Firestore.firestore()
            do {
                let snap = try await db
                    .collection("users")
                    .document(uid)
                    .getDocument()
                if let data = snap.data(),
                   let status = data["subscriptionStatus"] as? String {
                    await updateSubscriptionStatus(isPremium: status == "premium")
                }
            } catch {
                print("⚠️ Firestore fetch error: \(error.localizedDescription)")
            }
        }
    }

    func updateSubscriptionStatus(isPremium: Bool) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        do {
            let status = isPremium ? "premium" : "basic"
            try await db
                .collection("users")
                .document(uid)
                .updateData(["subscriptionStatus": status])
            isPremiumUser = isPremium
            user?.subscriptionStatus = status
        } catch {
            print("⚠️ Failed to update Firestore: \(error.localizedDescription)")
        }
    }

    // MARK: - Profile Image

    func fetchProfileImage() async {
        guard let urlStr = user?.profilePictureUrl,
              let url    = URL(string: urlStr) else {
            print("⚠️ No profile picture URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let img = UIImage(data: data) {
                profileImage = img
            } else {
                print("⚠️ Bad image data")
            }
        } catch {
            print("⚠️ Image download error: \(error.localizedDescription)")
        }
    }
}
