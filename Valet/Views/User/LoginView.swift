//
//  LoginView.swift
//  Valet
//
//  Created by Sia Khorsand on 3/7/25.
//

import SwiftUI
import Firebase

struct LoginView: View {
    @EnvironmentObject var userManager: UserManager
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var phoneNumber = ""
    @State private var name = ""
    @State private var verificationCode = ""
    @State private var isSignup = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var animate = false
    @State var showVerificationView: Bool
    @State private var isVerifying = false
    
    // Initialize with default parameters
    init(showVerificationView: Bool = false) {
        self._showVerificationView = State(initialValue: showVerificationView)
    }
    
    var body: some View {
        ZStack {
            // Dynamic background that adapts to color scheme
            ValetTheme.dynamicBackgroundGradient(colorScheme: colorScheme)
            
            // Animated particles
            ZStack {
                // Accent gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [
                        ValetTheme.dynamicColors(for: colorScheme).background,
                        ValetTheme.dynamicColors(for: colorScheme).background.opacity(0.9),
                        ValetTheme.dynamicColors(for: colorScheme).primary.opacity(0.1),
                        ValetTheme.dynamicColors(for: colorScheme).background.opacity(0.9)
                    ]),
                    startPoint: animate ? .bottomLeading : .topTrailing,
                    endPoint: animate ? .topTrailing : .bottomLeading
                )
                .ignoresSafeArea()
                
                // Particle effects
                ForEach(0..<20, id: \.self) { index in
                    FloatingParticle(
                        delay: Double(index) / 20.0,
                        size: CGFloat.random(in: 3...6)
                    )
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 15).repeatForever(autoreverses: true)) {
                    animate.toggle()
                }
            }
            
            if showVerificationView {
                // SMS Verification View
                VerificationView(
                    phoneNumber: phoneNumber,
                    name: name,
                    verificationCode: $verificationCode,
                    isVerifying: $isVerifying,
                    onVerify: verifyCode,
                    onCancel: { showVerificationView = false }
                )
                .transition(.move(edge: .trailing))
            } else {
                // Main Login View
                VStack(spacing: 30) {
                    // Logo and App Name
                    VStack(spacing: 15) {
                        ZStack {
                            // Glow effect
                            Circle()
                                .fill(ValetTheme.dynamicColors(for: colorScheme).primary)
                                .frame(width: 90, height: 90)
                                .blur(radius: 20)
                                .opacity(0.3)
                            
                            Image(systemName: "car.fill")
                                .font(.system(size: 60))
                                .foregroundColor(ValetTheme.dynamicColors(for: colorScheme).primary)
                                .shadow(color: ValetTheme.dynamicColors(for: colorScheme).primary.opacity(0.8), radius: 15, x: 0, y: 4)
                        }
                        
                        Text("VALET MANAGER")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(ValetTheme.dynamicColors(for: colorScheme).onBackground)
                            .tracking(2)
                            .shadow(color: ValetTheme.dynamicColors(for: colorScheme).primary.opacity(0.5), radius: 10, x: 0, y: 4)
                    }
                    .padding(.top, 50)
                    
                    // Form
                    VStack(spacing: 20) {
                        Text(isSignup ? "Create Account" : "Login")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(ValetTheme.dynamicColors(for: colorScheme).onSurface)
                        
                        // Name field (always shown)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(ValetTheme.dynamicColors(for: colorScheme).primary)
                                Text("NAME")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(ValetTheme.dynamicColors(for: colorScheme).primary)
                            }
                            
                            TextField("", text: $name)
                                .placeholder(when: name.isEmpty) {
                                    Text("Enter your name")
                                        .foregroundColor(ValetTheme.dynamicColors(for: colorScheme).textSecondary.opacity(0.7))
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(ValetTheme.dynamicColors(for: colorScheme).surfaceVariant)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(ValetTheme.dynamicColors(for: colorScheme).primary.opacity(0.6), lineWidth: 2)
                                )
                                .foregroundColor(ValetTheme.dynamicColors(for: colorScheme).onSurface)
                                .autocapitalization(.words)
                        }
                        
                        // Phone Number field
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "phone.fill")
                                    .foregroundColor(ValetTheme.dynamicColors(for: colorScheme).primary)
                                Text("PHONE NUMBER")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(ValetTheme.dynamicColors(for: colorScheme).primary)
                            }
                            
                            TextField("", text: $phoneNumber)
                                .placeholder(when: phoneNumber.isEmpty) {
                                    Text("Enter your phone number (e.g., +12345678900)")
                                        .foregroundColor(ValetTheme.dynamicColors(for: colorScheme).textSecondary.opacity(0.7))
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(ValetTheme.dynamicColors(for: colorScheme).surfaceVariant)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(ValetTheme.dynamicColors(for: colorScheme).primary.opacity(0.6), lineWidth: 2)
                                )
                                .foregroundColor(ValetTheme.dynamicColors(for: colorScheme).onSurface)
                                .keyboardType(.phonePad)
                                .textContentType(.telephoneNumber)
                        }
                        
                        // Login/Signup button
                        Button(action: startPhoneVerification) {
                            if userManager.isVerificationInProgress {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                            } else {
                                HStack {
                                    Image(systemName: isSignup ? "person.badge.plus" : "arrow.right.circle.fill")
                                        .font(.headline)
                                    Text(isSignup ? "Create Account" : "Continue")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .background(ValetTheme.dynamicPrimaryGradient(colorScheme: colorScheme))
                        .cornerRadius(12)
                        .shadow(color: ValetTheme.dynamicColors(for: colorScheme).primary.opacity(0.3), radius: 5, x: 0, y: 3)
                        .disabled(userManager.isVerificationInProgress)
                        
                        // Toggle between login and signup
                        Button(action: {
                            withAnimation {
                                isSignup.toggle()
                            }
                        }) {
                            Text(isSignup ? "Already have an account? Login" : "Don't have an account? Sign up")
                                .font(.subheadline)
                                .foregroundColor(ValetTheme.dynamicColors(for: colorScheme).primary)
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // App version
                    Text("Version 1.0")
                        .font(.caption)
                        .foregroundColor(ValetTheme.dynamicColors(for: colorScheme).textSecondary)
                        .padding(.bottom, 20)
                }
                .transition(.opacity)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    isVerifying = false
                }
            )
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    // Start phone verification process
    private func startPhoneVerification() {
        // Validate and process login/signup
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
           phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Please fill in all fields"
            showAlert = true
            return
        }
        
        // Make sure phone number is in the correct format
        var formattedNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        if !formattedNumber.hasPrefix("+") {
            formattedNumber = "+\(formattedNumber)"
        }
        
        userManager.startPhoneVerification(phoneNumber: formattedNumber) { success, error in
            if success {
                withAnimation {
                    self.showVerificationView = true
                }
            } else {
                self.alertMessage = error ?? "Failed to start verification"
                self.showAlert = true
            }
        }
    }
    
    // Verify SMS code
    private func verifyCode() {
        print("🔄 LoginView: Starting verification with code: \(verificationCode)")
        
        if verificationCode.count != 6 {
            alertMessage = "Please enter the 6-digit verification code"
            showAlert = true
            return
        }
        
        isVerifying = true
        
        // The actual verification happens in the UserManager
        userManager.verifyCode(code: verificationCode, name: name) { success, error in
            print("🔙 LoginView: Received verification callback - success: \(success)")
            
            DispatchQueue.main.async {
                if success {
                    print("✅ LoginView: Authentication successful")
                    // Authentication successful, the UserManager will update the isLoggedIn state
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                } else {
                    print("❌ LoginView: Authentication failed: \(error ?? "Unknown error")")
                    self.alertMessage = error ?? "Failed to verify code"
                    self.showAlert = true
                    
                    self.isVerifying = false
                }
            }
        }
    }
    
    // Helper to find a subview of specific type (for accessing the VerificationView)
    private func subviewOfType<T: View>(_ type: T.Type) -> T? {
        // This is a workaround for SwiftUI's limited view hierarchy access
        // In a real app, you would use Combine or a shared state object
        return nil
    }
    
    // Hide keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// Verification view for entering SMS code
struct VerificationView: View {
    let phoneNumber: String
    let name: String
    @Binding var verificationCode: String
    @Binding var isVerifying: Bool
    let onVerify: () -> Void
    let onCancel: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 10) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 60))
                    .foregroundColor(ValetTheme.dynamicColors(for: colorScheme).primary)
                    .shadow(color: ValetTheme.dynamicColors(for: colorScheme).primary.opacity(0.5), radius: 10, x: 0, y: 4)
                
                Text("Verification Code")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(ValetTheme.dynamicColors(for: colorScheme).onBackground)
                
                Text("We've sent a 6-digit code to\n\(phoneNumber)")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(ValetTheme.dynamicColors(for: colorScheme).textSecondary)
                    .padding(.top, 5)
            }
            .padding(.top, 50)
            
            // Verification code input
            VStack(alignment: .leading, spacing: 15) {
                Text("VERIFICATION CODE")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(ValetTheme.dynamicColors(for: colorScheme).primary)
                
                TextField("", text: $verificationCode)
                    .placeholder(when: verificationCode.isEmpty) {
                        Text("Enter 6-digit code")
                            .foregroundColor(ValetTheme.dynamicColors(for: colorScheme).textSecondary.opacity(0.7))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(ValetTheme.dynamicColors(for: colorScheme).surfaceVariant)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(ValetTheme.dynamicColors(for: colorScheme).primary.opacity(0.6), lineWidth: 2)
                    )
                    .foregroundColor(ValetTheme.dynamicColors(for: colorScheme).onSurface)
                    .keyboardType(.numberPad)
                    .onValueChange(of: verificationCode) { oldValue, newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        if filtered.count <= 6 {
                            verificationCode = filtered
                        } else {
                            verificationCode = String(filtered.prefix(6))
                        }
                    }
                    .disabled(isVerifying)
            }
            .padding(.horizontal, 30)
            
            // Buttons
            VStack(spacing: 15) {
                Button(action: {
                    isVerifying = true
                    onVerify()
                }) {
                    HStack {
                        if isVerifying {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 5)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.headline)
                        }
                        
                        Text(isVerifying ? "Verifying..." : "Verify")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                .background(ValetTheme.dynamicPrimaryGradient(colorScheme: colorScheme))
                .cornerRadius(12)
                .shadow(color: ValetTheme.dynamicColors(for: colorScheme).primary.opacity(0.3), radius: 5, x: 0, y: 3)
                .disabled(verificationCode.count != 6 || isVerifying)
                .opacity((verificationCode.count == 6 && !isVerifying) ? 1.0 : 0.6)
                
                Button(action: {
                    if !isVerifying {
                        onCancel()
                    }
                }) {
                    Text("Go Back")
                        .font(.subheadline)
                        .foregroundColor(ValetTheme.dynamicColors(for: colorScheme).primary)
                }
                .disabled(isVerifying)
                .opacity(isVerifying ? 0.5 : 1.0)
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Default state
            LoginView()
                .environmentObject(UserManager.shared)
                .previewDisplayName("Login - Light Mode")
            
            // With Dark Mode
            LoginView()
                .environmentObject(UserManager.shared)
                .preferredColorScheme(.dark)
                .previewDisplayName("Login - Dark Mode")
                
            // Verification state preview
            VerificationStatePreview()
                .environmentObject(UserManager.shared)
                .previewDisplayName("Verification Screen")
        }
    }
}

// Helper struct for verification preview
struct VerificationStatePreview: View {
    @State private var isShowingVerification = true
    
    var body: some View {
        LoginView(showVerificationView: isShowingVerification)
    }
}
#endif
