//
//  TermsView.swift
//  TestToDoList
//
//  Created by Tom Roney on 23/12/2024.
//

import SwiftUI

struct TermsView: View {
    @Environment(\.dismiss) var dismiss  // Allows us to dismiss this view

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // Title centered, styled like PrivacyView
                Text("Terms and Conditions")
                    .font(.title2)
                    .bold()
                    .padding()
                
                // Back button overlaid at the left edge
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
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("""
                    Thank you for choosing Develop Daily. These Terms and Conditions ("Terms") govern your access to and use of the Develop Daily application ("App"). By using the App, you agree to these Terms. Please read them carefully.
                    
                    1. Acceptance of Terms
                    
                    By accessing or using Develop Daily, you acknowledge that you have read, understood, and agree to be bound by these Terms. If you do not agree, you must not use the App.
                    
                    2. User Data and Privacy
                    
                    2.1 Data Collection and Storage
                    
                    - Develop Daily allows users to input and store personal and developmental data, including, but not limited to, notes, goals, and other self-improvement-related information ("User Data").
                    
                    - By using the App, you consent to the storage of all data you input within the App. This data will be stored securely to provide you with core functionalities, including saving your progress and improving your user experience.
                    
                    2.2 Data Security
                    
                    - We prioritize the security of your User Data and employ industry-standard measures to protect it. However, you acknowledge that no method of electronic storage is 100% secure, and we cannot guarantee absolute security.
                    
                    3. Digital Products
                    
                    3.1 Scope of Digital Products
                    
                    The App includes digital content such as templates, tools, and resources ("Digital Products"). By using the App, you acknowledge and accept that:
                    
                    - Any Digital Products accessed or downloaded through the App will be stored within the App's servers or associated storage systems.
                    
                    - You are solely responsible for ensuring that your use of these Digital Products complies with applicable laws and regulations.
                    
                    3.2 Ownership and Licensing
                    
                    All Digital Products remain the property of Develop Daily. You are granted a limited, non-exclusive, non-transferable license to use these products for personal purposes only.
                    
                    4. User Responsibilities
                    
                    - You are responsible for maintaining the confidentiality of your account credentials.
                    
                    - You must ensure that any data you input does not violate applicable laws or infringe the rights of third parties.
                    
                    5. Limitation of Liability
                    
                    Develop Daily is not liable for:
                    - Any loss, damage, or unauthorized access to your User Data caused by factors beyond our reasonable control.
                    
                    - Any indirect, incidental, or consequential damages arising from your use of the App.
                    
                    6. Modifications to the Terms
                    
                    We may revise these Terms from time to time. The updated Terms will be posted within the App and become effective immediately upon posting. Continued use of the App constitutes acceptance of the revised Terms.
                    
                    7. Governing Law
                    
                    These Terms are governed by and construed in accordance with the laws of [Insert Jurisdiction], without regard to its conflict of law principles.
                    
                    8. Contact Us
                    
                    If you have any questions or concerns about these Terms, please contact us at:
                    [Insert Contact Information]
                    
                    By continuing to use Develop Daily, you confirm your agreement to these Terms and Conditions. Thank you for being a part of our community.
                    """)
                    
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
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}
