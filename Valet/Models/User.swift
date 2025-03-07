//
//  User.swift
//  Valet
//
//  Created by Sia Khorsand on 3/7/25.
//


import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    var name: String
    var email: String
    
    init(id: UUID = UUID(), name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}

class UserManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    
    static let shared = UserManager()
    
    private let userDefaultsKey = "valet_user"
    private let loggedInKey = "valet_logged_in"
    
    private init() {
        loadUser()
    }
    
    // Load user from UserDefaults
    private func loadUser() {
        if UserDefaults.standard.bool(forKey: loggedInKey) {
            if let userData = UserDefaults.standard.data(forKey: userDefaultsKey),
               let user = try? JSONDecoder().decode(User.self, from: userData) {
                self.currentUser = user
                self.isLoggedIn = true
            }
        }
    }
    
    // Save user to UserDefaults
    private func saveUser() {
        if let user = currentUser, let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: userDefaultsKey)
            UserDefaults.standard.set(true, forKey: loggedInKey)
        }
    }
    
    // Login with email and password
    func login(email: String, name: String) {
        // In a real app, you would validate credentials against a backend
        // For this demo, we'll create a user and log them in directly
        let user = User(name: name, email: email)
        self.currentUser = user
        self.isLoggedIn = true
        saveUser()
    }
    
    // Update user information
    func updateUserInfo(name: String, email: String) {
        guard var user = currentUser else { return }
        user.name = name
        user.email = email
        self.currentUser = user
        saveUser()
    }
    
    // Logout user
    func logout() {
        self.currentUser = nil
        self.isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.set(false, forKey: loggedInKey)
    }
}
