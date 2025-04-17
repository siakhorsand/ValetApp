//
//  User.swift
//  Valet
//
//  Created by Sia Khorsand on 3/7/25.
//


import Foundation
import Firebase
import FirebaseAuth

struct User: Codable, Identifiable {
    let id: String
    var name: String
    var phoneNumber: String
    
    init(id: String = UUID().uuidString, name: String, phoneNumber: String) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
    }
    
    // Create a User from a Firebase User
    init?(firebaseUser: FirebaseAuth.User) {
        guard let phoneNumber = firebaseUser.phoneNumber else {
            return nil
        }
        
        self.id = firebaseUser.uid
        self.name = firebaseUser.displayName ?? "User"
        self.phoneNumber = phoneNumber
    }
    
    #if targetEnvironment(simulator)
    // Create a User from our MockFirebaseUser for simulator testing
    init?(mockUser: FirebaseAuthService.MockFirebaseUser) {
        guard let phoneNumber = mockUser.phoneNumber else {
            return nil
        }
        
        self.id = mockUser.uid
        self.name = mockUser.displayName ?? "User"
        self.phoneNumber = phoneNumber
    }
    #endif
}

class UserManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    @Published var isVerificationInProgress: Bool = false
    @Published var verificationID: String?
    
    static let shared = UserManager()
    
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    private init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        authStateListener = FirebaseAuthService.shared.addAuthStateChangeListener { [weak self] firebaseUser in
            guard let self = self else { return }
            
            if let firebaseUser = firebaseUser {
                if let appUser = User(firebaseUser: firebaseUser) {
                    self.currentUser = appUser
                    self.isLoggedIn = true
                } else if let phoneNumber = firebaseUser.phoneNumber {
                    // User exists in Firebase but has no display name yet
                    let newUser = User(id: firebaseUser.uid, name: "User", phoneNumber: phoneNumber)
                    self.currentUser = newUser
                    self.isLoggedIn = true
                } else {
                    self.currentUser = nil
                    self.isLoggedIn = false
                }
            } else {
                self.currentUser = nil
                self.isLoggedIn = false
            }
        }
    }
    
    deinit {
        if let listener = authStateListener {
            FirebaseAuthService.shared.removeAuthStateChangeListener(listener)
        }
    }
    
    // Start phone verification process
    func startPhoneVerification(phoneNumber: String, completion: @escaping (Bool, String?) -> Void) {
        // Make sure phone number has a + prefix
        var formattedNumber = phoneNumber
        if !formattedNumber.hasPrefix("+") {
            formattedNumber = "+\(formattedNumber)"
        }
        
        isVerificationInProgress = true
        
        FirebaseAuthService.shared.startPhoneNumberVerification(phoneNumber: formattedNumber) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isVerificationInProgress = false
                
                switch result {
                case .success(let verificationID):
                    self.verificationID = verificationID
                    completion(true, nil)
                    
                case .failure(let error):
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    // Verify SMS code and complete authentication
    func verifyCode(code: String, name: String, completion: @escaping (Bool, String?) -> Void) {
        print("👤 UserManager: Verifying code with name: \(name)")
        
        FirebaseAuthService.shared.verifyCode(verificationCode: code) { [weak self] result in
            guard let self = self else { 
                print("⚠️ UserManager: Self reference lost during verification")
                DispatchQueue.main.async {
                    completion(false, "Internal error: lost context during verification")
                }
                return 
            }
            
            switch result {
            case .success(let firebaseUser):
                print("✅ UserManager: Verification successful, creating app user")
                // Create app User from Firebase User
                if let appUser = User(firebaseUser: firebaseUser) {
                    print("👤 Created user from Firebase user: \(appUser.name)")
                    self.currentUser = appUser
                    self.isLoggedIn = true
                } else if let phoneNumber = firebaseUser.phoneNumber {
                    // Create a new User with the Firebase UID and phone number
                    print("👤 Creating new user from phone number: \(phoneNumber)")
                    let newUser = User(id: firebaseUser.uid, name: name, phoneNumber: phoneNumber)
                    self.currentUser = newUser
                    self.isLoggedIn = true
                } else {
                    print("⚠️ Firebase user has no phone number")
                }
                
                // Update user profile with the name
                print("🔄 Updating user profile with name: \(name)")
                self.updateUserProfile(name: name) { success, error in
                    DispatchQueue.main.async {
                        if success {
                            print("✅ Profile update successful")
                            completion(true, nil)
                        } else {
                            print("⚠️ Profile update failed: \(error ?? "Unknown error")")
                            // Still consider login successful even if profile update fails
                            completion(true, "Login successful but profile update failed: \(error ?? "Unknown error")")
                        }
                    }
                }
                
            case .failure(let error):
                #if targetEnvironment(simulator)
                // Check if this is our special simulator error
                let nsError = error as NSError
                if nsError.domain == "FirebaseAuthService.Simulator" && nsError.code == 1000 {
                    print("👤 Simulator mode: Creating test user")
                    
                    // Extract the simulator data from the error
                    let uid = nsError.userInfo["simulatorUID"] as? String ?? "sim-user-\(UUID().uuidString)"
                    let phoneNumber = nsError.userInfo["simulatorPhoneNumber"] as? String ?? "+1234567890"
                    
                    // Create a MockFirebaseUser
                    let mockUser = FirebaseAuthService.MockFirebaseUser(
                        uid: uid,
                        displayName: name,
                        phoneNumber: phoneNumber
                    )
                    
                    // Create a simulated user from the mock
                    if let simulatedUser = User(mockUser: mockUser) {
                        self.currentUser = simulatedUser
                        self.isLoggedIn = true
                        
                        print("✅ Simulator login successful")
                        DispatchQueue.main.async {
                            completion(true, nil)
                        }
                    } else {
                        print("❌ Failed to create user from mock")
                        DispatchQueue.main.async {
                            completion(false, "Failed to create user from mock data")
                        }
                    }
                    return
                }
                #endif
                
                print("❌ UserManager: Verification failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    // Update user profile with additional data
    func updateUserProfile(name: String, completion: @escaping (Bool, String?) -> Void) {
        FirebaseAuthService.shared.updateUserProfile(displayName: name) { result in
            switch result {
            case .success:
                completion(true, nil)
            case .failure(let error):
                completion(false, error.localizedDescription)
            }
        }
    }
    
    // Legacy login method that doesn't use Firebase (for backward compatibility)
    func login(phoneNumber: String, name: String) {
        // Start phone verification process
        startPhoneVerification(phoneNumber: phoneNumber) { [weak self] success, error in
            if !success, let error = error {
                print("Failed to start phone verification: \(error)")
                // For backward compatibility, create a local user
                let user = User(name: name, phoneNumber: phoneNumber)
                self?.currentUser = user
                self?.isLoggedIn = true
            }
        }
    }
    
    // Update user information
    func updateUserInfo(name: String, phoneNumber: String) {
        guard let currentUser = currentUser else { return }
        
        // Update local user model
        let updatedUser = User(id: currentUser.id, name: name, phoneNumber: phoneNumber)
        self.currentUser = updatedUser
        
        // Update Firebase profile
        updateUserProfile(name: name) { _, _ in }
    }
    
    // Logout user
    func logout() {
        FirebaseAuthService.shared.signOut { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.currentUser = nil
                    self?.isLoggedIn = false
                }
            case .failure(let error):
                print("Failed to sign out: \(error.localizedDescription)")
                // Force logout locally anyway
                DispatchQueue.main.async {
                    self?.currentUser = nil
                    self?.isLoggedIn = false
                }
            }
        }
    }
}
