//
//  JoinShiftView.swift
//  Valet
//
//  Created by Claude on 2/28/25.
//

import SwiftUI
import AVFoundation

struct JoinShiftView: View {
    @EnvironmentObject var shiftStore: ShiftStore
    @Environment(\.dismiss) var dismiss
    
    @State private var shiftCode: String = ""
    @State private var employeeName: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var successMessage: String? = nil
    @State private var navigateToShift: Bool = false
    @State private var foundShift: Shift? = nil
    @State private var showQRScanner = false
    @State private var codeFieldText = "" // Separate tracking for visible text
    @FocusState private var codeFieldFocused: Bool
    @FocusState private var nameFieldFocused: Bool
    @State private var cameraPermissionDenied = false
    
    // Auto-capitalize the shift code and format it while typing
    var formattedCode: Binding<String> {
        Binding(
            get: { self.shiftCode.uppercased() },
            set: { newValue in
                self.shiftCode = newValue.uppercased()
                
                // Also update the visible tracking field
                self.codeFieldText = newValue.uppercased()
            }
        )
    }
    
    var body: some View {
        ZStack {
            // Background
            ValetTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header with decorative elements
                HStack {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(ValetTheme.primary.opacity(0.5))
                    
                    Text("JOIN SHIFT")
                        .font(.headline)
                        .foregroundColor(ValetTheme.primary)
                        .padding(.horizontal, 10)
                    
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(ValetTheme.primary.opacity(0.5))
                }
                .padding(.top, 20)
                .padding(.horizontal)
                
                // Shift Code Input Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("SHIFT CODE")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(ValetTheme.textSecondary)
                    
                    // Code Input with character boxes and QR scan button
                    VStack(spacing: 12) {
                        // Character boxes
                        HStack(spacing: 8) {
                            ForEach(0..<6) { index in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(ValetTheme.surfaceVariant)
                                        .frame(width: 40, height: 50)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(codeFieldFocused ? ValetTheme.primary : ValetTheme.primary.opacity(0.5), lineWidth: 2)
                                        )
                                    
                                    if index < shiftCode.count {
                                        Text(String(shiftCode[shiftCode.index(shiftCode.startIndex, offsetBy: index)]))
                                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                                            .foregroundColor(ValetTheme.primary)
                                    } else if index == shiftCode.count && codeFieldFocused {
                                        // Show cursor at current position
                                        Rectangle()
                                            .fill(ValetTheme.primary)
                                            .frame(width: 2, height: 24)
                                            .opacity(1)
                                            .animation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: codeFieldFocused)
                                    }
                                }
                            }
                            
                            // QR Code scan button
                            Button(action: {
                                checkCameraPermission()
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(ValetTheme.secondary.opacity(0.2))
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(ValetTheme.secondary.opacity(0.5), lineWidth: 2)
                                        )
                                    
                                    Image(systemName: "qrcode.viewfinder")
                                        .font(.system(size: 24))
                                        .foregroundColor(ValetTheme.secondary)
                                }
                            }
                        }
                        
                        // Real hidden text field for keyboard input
                        ZStack {
                            if !codeFieldFocused {
                                Text("Tap to enter code")
                                    .foregroundColor(ValetTheme.textSecondary.opacity(0.7))
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            
                            TextField("", text: formattedCode)
                                .font(.system(.title3, design: .monospaced))
                                .foregroundColor(.clear) // Make text invisible
                                .accentColor(.clear) // Hide cursor
                                .disableAutocorrection(true)
                                .keyboardType(.asciiCapable)
                                .textInputAutocapitalization(.characters)
                                .focused($codeFieldFocused)
                                .onChange(of: shiftCode) { newValue in
                                    // Limit to 6 characters
                                    if newValue.count > 6 {
                                        shiftCode = String(newValue.prefix(6))
                                    }
                                    
                                    // Clear any previous error when typing
                                    if !newValue.isEmpty {
                                        errorMessage = nil
                                    }
                                }
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(ValetTheme.primary.opacity(0.3), lineWidth: 1)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            codeFieldFocused = true
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Employee Name Input
                VStack(alignment: .leading, spacing: 10) {
                    Text("YOUR NAME")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(ValetTheme.textSecondary)
                    
                    TextField("", text: $employeeName)
                        .placeholder(when: employeeName.isEmpty) {
                            Text("Enter your name")
                                .foregroundColor(ValetTheme.textSecondary.opacity(0.7))
                        }
                        .padding()
                        .background(ValetTheme.surfaceVariant)
                        .cornerRadius(12)
                        .foregroundColor(ValetTheme.onSurface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(nameFieldFocused ? ValetTheme.primary : ValetTheme.primary.opacity(0.5), lineWidth: 2)
                        )
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                        .focused($nameFieldFocused)
                        .submitLabel(.join)
                        .onSubmit {
                            if isFormValid {
                                joinShift()
                            }
                        }
                }
                .padding(.horizontal, 20)
                
                // Error/Success messages
                Group {
                    if let error = errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(ValetTheme.error)
                            Text(error)
                                .foregroundColor(ValetTheme.error)
                                .font(.footnote)
                        }
                        .padding(.horizontal)
                        .padding(.top, 5)
                    }
                    
                    if let success = successMessage {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(ValetTheme.success)
                            Text(success)
                                .foregroundColor(ValetTheme.success)
                                .font(.footnote)
                        }
                        .padding(.horizontal)
                        .padding(.top, 5)
                    }
                    
                    if cameraPermissionDenied {
                        HStack {
                            Image(systemName: "camera.fill.badge.ellipsis")
                                .foregroundColor(ValetTheme.warning)
                            Text("Camera access denied. Please enable camera access in Settings.")
                                .foregroundColor(ValetTheme.warning)
                                .font(.footnote)
                        }
                        .padding(.horizontal)
                        .padding(.top, 5)
                    }
                }
                
                Spacer()
                
                // Join button
                Button(action: joinShift) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(ValetTheme.primaryGradient)
                            .opacity(isFormValid ? 1.0 : 0.5)
                            .shadow(color: ValetTheme.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            HStack(spacing: 10) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.headline)
                                Text("Join Shift")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .padding()
                        }
                    }
                    .frame(height: 55)
                    .padding(.horizontal, 30)
                }
                .disabled(!isFormValid || isLoading)
                .padding(.bottom, 10)
                
                // Cancel button
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                        .font(.subheadline)
                        .foregroundColor(ValetTheme.textSecondary)
                }
                .padding(.bottom, 25)
            }
            .padding(.horizontal)
            .background(
                // Navigation link for when a shift is found
                Group {
                    if let shift = foundShift {
                        NavigationLink(
                            destination: ShiftDetailView(shift: shift),
                            isActive: $navigateToShift
                        ) {
                            EmptyView()
                        }
                    }
                }
            )
        }
        .fullScreenCover(isPresented: $showQRScanner) {
            QRCodeScannerView(scannedCode: $shiftCode, isShowing: $showQRScanner)
                .edgesIgnoringSafeArea(.all)
                .preferredColorScheme(.dark)
                .onDisappear {
                    // Check if we got a valid code
                    if shiftCode.count == 6 {
                        // Haptic feedback when code is scanned
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    }
                }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            // Set focus after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                codeFieldFocused = true
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // Form validation
    private var isFormValid: Bool {
        shiftCode.count == 6 && !employeeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Check camera permission
    private func checkCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    showQRScanner = true
                    cameraPermissionDenied = false
                } else {
                    cameraPermissionDenied = true
                }
            }
        }
    }
    
    // Join shift logic
    private func joinShift() {
        hideKeyboard()
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        shiftStore.fetchShiftFromCloud(byCode: shiftCode) { result in
            isLoading = false
            
            switch result {
            case .success(let shift):
                if let shift = shift {
                    // Add the employee to the shift
                    shiftStore.addEmployeeToShift(name: employeeName, shift: shift)
                    
                    // Set success message and prepare for navigation
                    successMessage = "Successfully joined shift!"
                    foundShift = shift
                    
                    // Haptic feedback for success
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                    // Navigate after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        navigateToShift = true
                    }
                } else {
                    errorMessage = "Shift not found. Please check the code and try again."
                    // Haptic feedback for error
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                }
                
            case .failure(let error):
                errorMessage = error.localizedDescription
                // Haptic feedback for error
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
        }
    }
    
    // Hide keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
