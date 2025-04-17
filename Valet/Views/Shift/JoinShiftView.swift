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
    @EnvironmentObject var userManager: UserManager
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
        Binding<String>(
            get: { getFormattedCode() },
            set: { updateFormattedCode($0) }
        )
    }
    
    // Helper method to get the formatted code
    private func getFormattedCode() -> String {
        return shiftCode.uppercased()
    }
    
    // Helper method to set the formatted code
    private func updateFormattedCode(_ newValue: String) {
        shiftCode = newValue.uppercased()
        // Also update the visible tracking field
        codeFieldText = newValue.uppercased()
    }
    
    var body: some View {
        ZStack {
            // Background
            ValetTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                headerView()
                shiftCodeInputView()
                userNameSectionView()
                messagesView()
                Spacer()
                actionButtonsView()
            }
            .padding(.horizontal)
            .background(navigationLinkView())
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
            // Auto-populate employee name from user profile
            if let user = userManager.currentUser {
                employeeName = user.name
            }
            
            // Set focus after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                codeFieldFocused = true
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Subviews
    
    private func headerView() -> some View {
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
    }
    
    private func shiftCodeInputView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SHIFT CODE")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(ValetTheme.textSecondary)
            
            codeInputFieldsView()
        }
        .padding(.horizontal, 20)
    }
    
    private func codeInputFieldsView() -> some View {
        VStack(spacing: 12) {
            // Character boxes
            HStack(spacing: 8) {
                ForEach(0..<6) { index in
                    codeCharacterBoxView(index: index)
                }
                
                qrCodeScanButton()
            }
            
            hiddenTextField()
        }
    }
    
    private func codeCharacterBoxView(index: Int) -> some View {
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
    
    private func qrCodeScanButton() -> some View {
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
    
    private func hiddenTextField() -> some View {
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
                .onValueChange(of: shiftCode) { oldValue, newValue in
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
    
    private func userNameSectionView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("YOUR NAME")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(ValetTheme.textSecondary)
            
            HStack {
                Text(userManager.currentUser?.name ?? "")
                    .padding()
                    .foregroundColor(ValetTheme.onSurface)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(ValetTheme.surfaceVariant)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(ValetTheme.primary.opacity(0.5), lineWidth: 2)
                    )
                
                profileBadgeView()
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func profileBadgeView() -> some View {
        HStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(ValetTheme.primary)
                    .frame(width: 24, height: 24)
                
                Text(userManager.currentUser?.name.prefix(1).uppercased() ?? "U")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text("Profile")
                .font(.caption)
                .foregroundColor(ValetTheme.primary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(ValetTheme.primary.opacity(0.5), lineWidth: 1)
        )
    }
    
    private func messagesView() -> some View {
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
    }
    
    private func actionButtonsView() -> some View {
        VStack(spacing: 10) {
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
    }
    
    private func navigationLinkView() -> some View {
        Group {
            if let shift = foundShift {
                Group {
                    if let shift = foundShift {
                        // Use the same NavigationLink initializer for both iOS versions
                        NavigationLink(
                            destination: ShiftDetailView(shift: shift),
                            isActive: $navigateToShift
                        ) {
                            EmptyView()
                        }
                    }
                }
            }
        }
    }
    
    // Form validation
    private var isFormValid: Bool {
        shiftCode.count == 6 && userManager.currentUser != nil
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
        guard let user = userManager.currentUser else { return }
        
        hideKeyboard()
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        shiftStore.fetchShiftFromCloud(byCode: shiftCode) { result in
            isLoading = false
            
            switch result {
            case .success(let shift):
                if let shift = shift {
                    // Add the employee to the shift using the current user's name
                    shiftStore.addEmployeeToShift(name: user.name, shift: shift)
                    
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
#if DEBUG
struct JoinShiftView_Previews: PreviewProvider {
    static var previews: some View {
        JoinShiftView()
            .environmentObject(ShiftStore(withDemoData: true))
            .environmentObject(UserManager.shared)
            .preferredColorScheme(.dark)
    }
}
#endif
