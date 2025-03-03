//
//  NewShiftSheet.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//

import SwiftUI

struct NewShiftSheet: View {
    @EnvironmentObject var shiftStore: ShiftStore
    @Environment(\.dismiss) var dismiss

    @State private var customerName = ""
    @State private var address = ""
    @State private var animateContent = false

    // Callbacks: pass the new shift ID back to ContentView and handle cancel
    let onShiftCreated: (UUID) -> Void
    let onCancel: () -> Void

    var body: some View {
        // Sheet content - centered on screen
        VStack(spacing: 0) {
            // Stylish header
            VStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(ValetTheme.primary)
                    .padding(.top, 25)
                    .offset(y: animateContent ? 0 : -20)
                    .opacity(animateContent ? 1 : 0)
                
                Text("Start a New Shift")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(ValetTheme.onSurface)
                    .offset(y: animateContent ? 0 : -10)
                    .opacity(animateContent ? 1 : 0)
                
                // Subtle divider
                Rectangle()
                    .frame(width: 60, height: 3)
                    .foregroundColor(ValetTheme.primary)
                    .cornerRadius(1.5)
                    .padding(.bottom, 8)
                    .scaleEffect(animateContent ? 1 : 0.3)
                    .opacity(animateContent ? 1 : 0)
            }
            .padding(.bottom, 20)

            // Input fields
            VStack(spacing: 20) {
                // Customer Name field
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(ValetTheme.primary)
                        Text("CUSTOMER NAME")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(ValetTheme.primary)
                    }
                    
                    TextField("", text: $customerName)
                        .placeholder(when: customerName.isEmpty) {
                            Text("Enter customer name")
                                .foregroundColor(ValetTheme.textSecondary.opacity(0.7))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ValetTheme.surfaceVariant)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(ValetTheme.primary.opacity(0.6), lineWidth: 2)
                        )
                        .foregroundColor(ValetTheme.onSurface)
                        .autocapitalization(.words)
                }
                .offset(y: animateContent ? 0 : 10)
                .opacity(animateContent ? 1 : 0)
                
                // Address field
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(ValetTheme.primary)
                        Text("ADDRESS")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(ValetTheme.primary)
                    }
                    
                    TextField("", text: $address)
                        .placeholder(when: address.isEmpty) {
                            Text("Enter venue address")
                                .foregroundColor(ValetTheme.textSecondary.opacity(0.7))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ValetTheme.surfaceVariant)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(ValetTheme.primary.opacity(0.6), lineWidth: 2)
                        )
                        .foregroundColor(ValetTheme.onSurface)
                }
                .offset(y: animateContent ? 0 : 10)
                .opacity(animateContent ? 1 : 0)
            }
            .padding(.horizontal, 25)
            .padding(.bottom, 30)

            // Action buttons
            HStack(spacing: 15) {
                Button("Cancel") {
                    onCancel()
                }
                .font(.headline)
                .foregroundColor(ValetTheme.textSecondary)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ValetTheme.surfaceVariant.opacity(0.7))
                )
                
                Button("Create Shift") {
                    guard !customerName.isEmpty, !address.isEmpty else { return }
                    let newShift = shiftStore.startShift(customerName: customerName, address: address)
                    
                    // Haptic feedback
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                    onShiftCreated(newShift.id)
                    onCancel() // Use onCancel instead of dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(!customerName.isEmpty && !address.isEmpty ?
                              ValetTheme.primaryGradient :
                              LinearGradient(
                                  gradient: Gradient(colors: [ValetTheme.surfaceVariant, ValetTheme.surfaceVariant]),
                                  startPoint: .leading,
                                  endPoint: .trailing
                              )
                        )
                )
                .disabled(customerName.isEmpty || address.isEmpty)
            }
            .padding(.horizontal, 25)
            .padding(.bottom, 30)
            .offset(y: animateContent ? 0 : 20)
            .opacity(animateContent ? 1 : 0)
        }
        .frame(width: 350, height: 400)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(ValetTheme.background)
                .shadow(color: Color.black.opacity(0.5), radius: 16, x: 0, y: 8)
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateContent = true
            }
        }
        // Center the modal in the screen
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .preferredColorScheme(.dark)
    }
}
