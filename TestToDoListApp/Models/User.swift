//
//  User.swift
//  TestToDoList
//
//  Created by Tom Roney on 30/07/2024.
//

import Foundation

struct User {
    var id: String
    var firstname: String
    var surname: String
    var email: String
    var joined: TimeInterval
    var profilePictureUrl: String?
    var subscriptionStatus: String
    var dateOfBirth: String
    var countryOfResidence: String
    var agreedToTerms: Bool
    var mailingList: Bool // New property

    func asDictionary() -> [String: Any] {
        return [
            "id": id,
            "firstname": firstname,
            "surname": surname,
            "email": email,
            "joined": joined,
            "profilePictureUrl": profilePictureUrl ?? "",
            "subscriptionStatus": subscriptionStatus,
            "dateOfBirth": dateOfBirth,
            "countryOfResidence": countryOfResidence,
            "agreedToTerms": agreedToTerms,
            "mailingList": mailingList // Add mailingList to the dictionary
        ]
    }
}

