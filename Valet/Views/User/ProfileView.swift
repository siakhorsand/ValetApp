//
//  ProfileView.swift
//  Valet
//
//  Created by Sia Khorsand on 3/7/25.
//


import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userManager: UserManager
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var name: String = ""
    @State private var phoneNumber: String = ""
    @State private var showLogoutConfirmation = false
    @State private var showSavedAlert = false
    
    var body: some View {
        ZStack {
            // Background that adapts to color scheme
            ValetTheme.dynamicColors(for: colorScheme).background
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(ValetTheme.dynamicColors(for: colorScheme).primary.opacity(0.5))
                    
                    Text("PROFILE")
                        .font(.headline)
                        .foregroundColor(ValetTheme.dynamicColors(for: colorScheme).primary)
                        .padding(.horizontal, 10)
                    
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(ValetTheme.dynamicColors(for: colorScheme).primary.opacity(0.5))
                }
                .padding(.top, 20)
                .padding(.horizontal)
                
                // Profile avatar
                ZStack {
                    Circle()
                        .fill(ValetTheme.dynamicColors(for: colorScheme).primary)
                        .frame(width: 90, height: 90)
                    
                    Text(userManager.currentUser?.name.prefix(1).uppercased() ?? "U")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 10)
                
                // Form
                VStack(spacing: 20) {
                    // Name field
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
                    
                    // Save button
                    Button(action: saveProfile) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.headline)
                            Text("Save Changes")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(ValetTheme.dynamicPrimaryGradient(colorScheme: colorScheme))
                        .cornerRadius(12)
                        .shadow(color: ValetTheme.dynamicColors(for: colorScheme).primary.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                              phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Logout button
                Button(action: {
                    showLogoutConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.headline)
                        Text("Logout")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(ValetTheme.dynamicColors(for: colorScheme).error.opacity(0.8))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .alert("Saved", isPresented: $showSavedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your profile has been updated successfully.")
        }
        .alert("Logout", isPresented: $showLogoutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                userManager.logout()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
        .onAppear {
            if let user = userManager.currentUser {
                name = user.name
                phoneNumber = user.phoneNumber
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private func saveProfile() {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        userManager.updateUserInfo(name: name, phoneNumber: phoneNumber)
        
        // Show success alert
        showSavedAlert = true
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // Hide keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        // Setup a mock user for preview
        let manager = UserManager.shared
        // Create a user if not present for preview
        if manager.currentUser == nil {
            manager.login(phoneNumber: "858-393-0039", name: "Dani Tabai")
        }
        
        return ProfileView()
            .environmentObject(manager)
            .preferredColorScheme(.dark)
    }
}
#endif
