//
//  PrivacyView.swift
//  TestToDoList
//
//  Created by Tom Roney on 23/12/2024.
//

import SwiftUI

struct PrivacyView: View {
    @Environment(\.dismiss) var dismiss  // Allows us to dismiss this view

    var body: some View {
        VStack(spacing: 0) {
            // Custom navigation header using a ZStack
            ZStack {
                // Centered title
                Text("Privacy Policy")
                    .font(.title2)
                    .bold()
                    .padding()
                
                // Back button overlaid on the left
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                    .foregroundColor(Color("GreenText"))
                    .padding(.leading)
                    Spacer()
                }
            }
            
            Divider()
            
            // Main content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("""
                    This Privacy Policy explains how Develop Daily ("we", "our", or "the App") collects, uses, stores, and protects your personal data ("User Data"). By using the App, you agree to the collection and use of information in accordance with this policy. Please read this policy carefully to understand how we handle your data.

                    1. Information We Collect
                    
                    When you use Develop Daily, we collect and store various types of information, including:

                    Personal Information: Information you provide to us directly when you register or use the App, such as your name, email address, and other personal details.

                    User Data: Data you input into the App, including notes, goals, and any other self-improvement-related information.

                    Usage Data: Information about how you use the App, such as device information, IP address, log data, and interaction data to help us improve the user experience.

                    2. How We Use Your Information
                    
                    We use your data for the following purposes:

                    To Provide Services: To operate, maintain, and enhance the App, including saving your progress and personal data for a personalized experience.

                    To Improve User Experience: We may use aggregated and anonymized data to analyze usage trends and improve the App's functionality.

                    To Communicate: To respond to your inquiries, provide support, and send important notifications about the App's updates or changes.

                    To Comply with Legal Obligations: We may process your data to comply with applicable laws or legal requests.

                    3. Data Security
                    
                    We take reasonable steps to protect your data from unauthorized access, alteration, or destruction. However, no method of data transmission or storage is completely secure, and we cannot guarantee absolute security.

                    4. Data Retention
                    
                    We retain your personal data for as long as necessary to fulfill the purposes outlined in this Privacy Policy or as required by law. If you wish to delete your data, you may request it by contacting us at [Insert Contact Information].

                    5. Sharing Your Information
                    
                    We do not sell, trade, or rent your personal data to third parties. We may share your information only in the following situations:

                    With Service Providers: We may share your data with trusted third-party service providers who assist us in operating the App, such as cloud storage providers or analytics services.

                    For Legal Compliance: We may disclose your information if required to do so by law, to enforce our Terms and Conditions, or to protect the rights, property, or safety of Develop Daily, its users, or others.

                    6. Your Data Rights
                    
                    You have certain rights regarding your personal data, including:

                    Access and Correction: You can access and update your personal information at any time through your account settings.

                    Data Deletion: You can request to delete your data by contacting us directly. We will delete your data in accordance with applicable laws.

                    Opt-out of Communications: You can opt-out of promotional or marketing communications by following the instructions in the communication or by contacting us directly.

                    7. Cookies and Tracking Technologies
                    
                    We may use cookies and similar tracking technologies to enhance your experience and collect information about how you interact with the App. You can manage your cookie preferences through your device settings.

                    8. Changes to This Privacy Policy
                    
                    We may update this Privacy Policy from time to time. The updated policy will be posted in the App, and the changes will take effect immediately upon posting. Continued use of the App constitutes your acceptance of the updated Privacy Policy.

                    9. Contact Us
                    
                    If you have any questions or concerns about our Privacy Policy or how we handle your data, please contact us at:

                    [Insert Contact Information]

                    By using Develop Daily, you consent to the collection and use of your personal data as outlined in this Privacy Policy.
                    """)
                    .font(.body)
                    .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}
