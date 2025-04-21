//
//  MainViewViewModel.swift
//  TestToDoList
//
//  Created by Tom Roney on 30/07/2024.
//

import FirebaseAuth
import Foundation

class MainViewViewModel:ObservableObject {
    @Published var currentUserId: String = ""
    private var handler: AuthStateDidChangeListenerHandle?
    
    init () {
        self.handler = Auth.auth().addStateDidChangeListener { [weak self] _, User in
            DispatchQueue.main.async {
                self?.currentUserId = User?.uid ?? ""
            }
        }
        
    }
    
    public var isSignedIn: Bool {
        return Auth.auth().currentUser != nil
    }
}
