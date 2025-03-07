//
//  LoginView.swift
//  Valet
//
//  Created by Sia Khorsand on 3/7/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userManager: UserManager
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var phoneNumber = ""
    @State private var name = ""
    @State private var isSignup = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var animate = false
    
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
                                Text("Enter your phone number")
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
                    Button(action: {
                        // Validate and process login/signup
                        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                           phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            alertMessage = "Please fill in all fields"
                            showAlert = true
                            return
                        }
                        
                        // For demo, just log in the user with the provided name
                        userManager.login(phoneNumber: phoneNumber, name: name)
                        
                        // Provide haptic feedback for success
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    }) {
                        HStack {
                            Image(systemName: isSignup ? "person.badge.plus" : "arrow.right.circle.fill")
                                .font(.headline)
                            Text(isSignup ? "Create Account" : "Login")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(ValetTheme.dynamicPrimaryGradient(colorScheme: colorScheme))
                        .cornerRadius(12)
                        .shadow(color: ValetTheme.dynamicColors(for: colorScheme).primary.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    
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
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    // Hide keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Default state
            LoginView()
                .environmentObject(UserManager.shared)
            
            // With Dark Mode
            LoginView()
                .environmentObject(UserManager.shared)
                .preferredColorScheme(.dark)
        }
    }
}
#endif
