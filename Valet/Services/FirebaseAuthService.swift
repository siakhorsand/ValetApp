//
//  FirebaseAuthService.swift
//  Valet
//
//  Created by Sia Khorsand on 3/7/25.
//

import Foundation
import Firebase
import FirebaseAuth

class FirebaseAuthService {
    static let shared = FirebaseAuthService()
    
    private init() {}
    
    // MARK: - Phone Authentication
    
    /// Start phone number verification process
    /// - Parameters:
    ///   - phoneNumber: Phone number in international format (e.g., +12345678900)
    ///   - completion: Callback with verification ID or error
    func startPhoneNumberVerification(phoneNumber: String, completion: @escaping (Result<String, Error>) -> Void) {
        print("🔐 Starting phone verification for: \(phoneNumber)")
        
        // For testing in simulator, use a fake verification ID
        #if targetEnvironment(simulator)
        // This simulates the verification process for simulators where SMS can't be received
        print("📱 Running in simulator - using test verification")
        let testVerificationID = "test-verification-id-\(UUID().uuidString)"
        UserDefaults.standard.set(testVerificationID, forKey: "authVerificationID")
        
        // Short delay to simulate network call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(testVerificationID))
        }
        return
        #endif
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                print("❌ Phone verification failed: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let verificationID = verificationID {
                print("✅ Phone verification started successfully. Verification ID: \(verificationID)")
                // Save verification ID to UserDefaults for later use
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                completion(.success(verificationID))
            } else {
                print("❌ No verification ID received but no error either")
                let error = NSError(domain: "FirebaseAuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Verification ID is nil"])
                completion(.failure(error))
            }
        }
    }
    
    /// Verify SMS code to complete authentication
    /// - Parameters:
    ///   - verificationCode: 6-digit code received via SMS
    ///   - completion: Callback with success or error
    func verifyCode(verificationCode: String, completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void) {
        print("🔐 Verifying code: \(verificationCode)")
        
        #if targetEnvironment(simulator)
        // For simulator testing, we'll skip the Firebase auth and return a special error
        print("📱 Running in simulator - skipping Firebase authentication")
        let simError = NSError(
            domain: "FirebaseAuthService.Simulator",
            code: 1000,
            userInfo: [
                NSLocalizedDescriptionKey: "SIMULATOR_AUTH",
                "simulatorUID": "sim-\(UUID().uuidString)",
                "simulatorPhoneNumber": "+1234567890"
            ]
        )
        // Return our special error that will be handled by UserManager
        completion(.failure(simError))
        return
        #endif
        
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else {
            print("❌ Verification failed: No verification ID found in UserDefaults")
            let error = NSError(domain: "FirebaseAuthService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No verification ID found"])
            completion(.failure(error))
            return
        }
        
        print("📱 Using verification ID: \(verificationID)")
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )
        
        print("🔑 Created credential, attempting sign in...")
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("❌ Sign in failed: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let user = authResult?.user {
                print("✅ Sign in successful for user: \(user.uid)")
                print("📱 Phone: \(user.phoneNumber ?? "No phone")")
                print("👤 Name: \(user.displayName ?? "No name")")
                completion(.success(user))
            } else {
                print("❌ Authentication succeeded but no user was returned")
                let error = NSError(domain: "FirebaseAuthService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Authentication succeeded but no user was returned"])
                completion(.failure(error))
            }
        }
    }
    
    /// Update user profile with additional data
    /// - Parameters:
    ///   - displayName: User's name
    ///   - completion: Callback with success or error
    func updateUserProfile(displayName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            let error = NSError(domain: "FirebaseAuthService", code: 3, userInfo: [NSLocalizedDescriptionKey: "No authenticated user found"])
            completion(.failure(error))
            return
        }
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        
        changeRequest.commitChanges { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }
    }
    
    /// Sign out current user
    /// - Parameter completion: Callback with success or error
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: "authVerificationID")
            completion(.success(()))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    /// Get the current authenticated user
    /// - Returns: Current Firebase user or nil if not authenticated
    func getCurrentUser() -> FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
    
    /// Check if user is currently signed in
    /// - Returns: Boolean indicating signed in status
    func isUserSignedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    /// Add auth state change listener
    /// - Parameter handler: Callback when auth state changes
    /// - Returns: Handle used to remove the listener
    @discardableResult
    func addAuthStateChangeListener(handler: @escaping (FirebaseAuth.User?) -> Void) -> AuthStateDidChangeListenerHandle {
        return Auth.auth().addStateDidChangeListener { (_, user) in
            handler(user)
        }
    }
    
    /// Remove auth state change listener
    /// - Parameter handle: Handle from addAuthStateChangeListener
    func removeAuthStateChangeListener(_ handle: AuthStateDidChangeListenerHandle) {
        Auth.auth().removeStateDidChangeListener(handle)
    }
    
    #if targetEnvironment(simulator)
    // Mock Firebase User for simulator testing
    class MockFirebaseUser {
        let uid: String
        let displayName: String?
        let phoneNumber: String?
        
        init(uid: String, displayName: String?, phoneNumber: String?) {
            self.uid = uid
            self.displayName = displayName
            self.phoneNumber = phoneNumber
        }
    }
    #endif
} 