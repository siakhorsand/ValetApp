//
//  EmployeeSheet.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//

import SwiftUI

struct EmployeeSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var shiftStore: ShiftStore
    @EnvironmentObject var userManager: UserManager

    @State private var newEmployeeName = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            // Background
            ValetTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(ValetTheme.primary.opacity(0.5))
                    
                    Text("TEAM MEMBERS")
                        .font(.headline)
                        .foregroundColor(ValetTheme.primary)
                        .padding(.horizontal, 10)
                    
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(ValetTheme.primary.opacity(0.5))
                }
                .padding(.top, 20)
                .padding(.horizontal)
                
                // Current user section - highlighted as "You"
                if let currentUser = userManager.currentUser {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("YOUR PROFILE")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(ValetTheme.primary.opacity(0.8))
                            .padding(.horizontal)
                        
                        // Check if the current user already exists as an employee
                        let userEmployee = shiftStore.allEmployees.first(where: { $0.name == currentUser.name })
                        
                        HStack {
                            // Avatar with color if existing employee, otherwise default
                            ZStack {
                                Circle()
                                    .fill(userEmployee?.color ?? ValetTheme.primary)
                                    .frame(width: 40, height: 40)
                                
                                Text(currentUser.name.prefix(1).uppercased())
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            // User info
                            VStack(alignment: .leading, spacing: 2) {
                                Text(currentUser.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(ValetTheme.onSurface)
                                
                                Text("You")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(ValetTheme.primary.opacity(0.2))
                                    .cornerRadius(4)
                                    .foregroundColor(ValetTheme.primary.opacity(0.8))
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ValetTheme.surfaceVariant.opacity(0.7))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(userEmployee?.color.opacity(0.4) ?? ValetTheme.primary.opacity(0.4), lineWidth: 2)
                        )
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 10)
                }
                
                // Employee list
                VStack(alignment: .leading, spacing: 10) {
                    Text("OTHER TEAM MEMBERS")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(ValetTheme.primary.opacity(0.8))
                        .padding(.horizontal)
                    
                    if shiftStore.allEmployees.isEmpty {
                        VStack(spacing: 15) {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 40))
                                .foregroundColor(ValetTheme.textSecondary.opacity(0.3))
                            
                            Text("No team members yet")
                                .font(.headline)
                                .foregroundColor(ValetTheme.textSecondary)
                            
                            Text("Add your first team member below")
                                .font(.subheadline)
                                .foregroundColor(ValetTheme.textSecondary.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        // Filter out the current user if they're already in the list
                        let otherEmployees = userManager.currentUser != nil ?
                            shiftStore.allEmployees.filter { $0.name != userManager.currentUser!.name } :
                            shiftStore.allEmployees
                            
                        if otherEmployees.isEmpty {
                            Text("No other team members yet")
                                .font(.subheadline)
                                .foregroundColor(ValetTheme.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 20)
                        } else {
                            ScrollView {
                                LazyVGrid(
                                    columns: [
                                        GridItem(.flexible()),
                                        GridItem(.flexible())
                                    ],
                                    spacing: 16
                                ) {
                                    ForEach(otherEmployees) { emp in
                                        EmployeeCard(employee: emp)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .frame(maxHeight: 300)
                        }
                    }
                }
                
                // Add employee section - cleaner UI
                VStack(spacing: 16) {
                    Text("Add New Team Member")
                        .font(.headline)
                        .foregroundColor(ValetTheme.onSurface)
                    
                    HStack(spacing: 10) {
                        TextField("", text: $newEmployeeName)
                            .placeholder(when: newEmployeeName.isEmpty) {
                                Text("Enter name")
                                    .foregroundColor(ValetTheme.textSecondary.opacity(0.7))
                            }
                            .padding()
                            .background(ValetTheme.surfaceVariant)
                            .cornerRadius(12)
                            .foregroundColor(ValetTheme.onSurface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(ValetTheme.primary.opacity(0.5), lineWidth: 2)
                            )
                            .autocapitalization(.words)
                        
                        Button(action: addEmployee) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(13)
                                .background(
                                    !newEmployeeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                                        ValetTheme.primaryGradient :
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.4)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                )
                                .cornerRadius(12)
                        }
                        .disabled(newEmployeeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Done button
                Button(action: {
                    dismiss()
                }) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(ValetTheme.accentGradient)
                        .cornerRadius(12)
                        .shadow(color: ValetTheme.secondary.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Note"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .preferredColorScheme(.dark)
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private func addEmployee() {
        let trimmedName = newEmployeeName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        // Check if an employee with this name already exists
        if shiftStore.allEmployees.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) {
            alertMessage = "A team member with this name already exists."
            showAlert = true
            return
        }
        
        // Check if this is the current user's name
        if let currentUser = userManager.currentUser, currentUser.name.lowercased() == trimmedName.lowercased() {
            alertMessage = "This is your own name. You're already part of the team."
            showAlert = true
            return
        }
        
        shiftStore.addEmployee(name: trimmedName)
        newEmployeeName = ""
        
        // Success haptic
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // Hide keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// Employee Card View - Slightly updated for better visual consistency
struct EmployeeCard: View {
    let employee: Employee
    
    var body: some View {
        HStack(spacing: 12) {
            // Employee avatar with color
            ZStack {
                Circle()
                    .fill(employee.color)
                    .frame(width: 36, height: 36)
                
                Text(employee.name.prefix(1).uppercased())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Name with max width constraints
            Text(employee.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(ValetTheme.onSurface)
                .lineLimit(1)
            
            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(ValetTheme.surfaceVariant.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(employee.color.opacity(0.4), lineWidth: 1.5)
        )
    }
}
#if DEBUG
struct EmployeeSheet_Previews: PreviewProvider {
    static var previews: some View {
        EmployeeSheet()
            .environmentObject(ShiftStore(withDemoData: true))
            .environmentObject(UserManager.shared)
            .preferredColorScheme(.dark)
    }
}
#endif
