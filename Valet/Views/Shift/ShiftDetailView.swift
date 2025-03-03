//
//  ShiftDetailView.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//

import SwiftUI

struct ShiftDetailView: View {
    @EnvironmentObject var shiftStore: ShiftStore
    let shift: Shift

    @State private var showAddCarSheet = false
    @State private var showEmployeeSheet = false
    @State private var isShareSheetPresented = false
    @State private var showQRCode = false
    @State private var animateContent = false

    // For "End Shift" hold
    @State private var isHoldingEndShift = false
    @State private var endShiftCountdown = 5
    @State private var pulsingRed = false

    // Toggling between original layout (single row)
    // or alternative grid (3-4 in a row, color only).
    @State private var showAlternativeLayout = false

    var cars: [Car] {
        shiftStore.shifts.first(where: { $0.id == shift.id })?.cars ?? []
    }

    // Abbreviated name, e.g., "J. Smith"
    var abbreviatedCustomerName: String {
        shift.customerName.abbreviatedName()
    }

    // Round shift.startTime to nearest 15, format as "h a" -> "6 PM"
    var roundedStartTimeString: String {
        let rounded = shift.startTime.roundedToNearest15Min()
        return rounded.toHourString()
    }

    // Combined top label: e.g. "Smith St. @ 6PM"
    var topLabel: String {
        "\(shift.address) @ \(roundedStartTimeString)"
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    ValetTheme.background,
                    ValetTheme.primaryVariant.opacity(0.15),
                    ValetTheme.background
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Card with slide-in animation
                VStack(spacing: 12) {
                    // Top row with customer name and toggle button
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "person.fill")
                                .foregroundColor(ValetTheme.primary)
                            
                            Text("\(abbreviatedCustomerName)")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(ValetTheme.onSurface)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 10)
                        .background(ValetTheme.surfaceVariant.opacity(0.5))
                        .cornerRadius(8)
                        .offset(x: animateContent ? 0 : -50)
                        .opacity(animateContent ? 1 : 0)

                        Spacer()

                        // Toggle layout button
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                showAlternativeLayout.toggle()
                            }
                        }) {
                            Image(systemName: showAlternativeLayout ? "list.bullet" : "rectangle.grid.2x2")
                                .font(.title3)
                                .foregroundColor(ValetTheme.primary)
                                .padding(8)
                                .background(ValetTheme.surfaceVariant)
                                .cornerRadius(8)
                        }
                        .offset(x: animateContent ? 0 : 50)
                        .opacity(animateContent ? 1 : 0)
                    }

                    // Address and time with fade-in animation
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .foregroundColor(ValetTheme.textSecondary)
                            .font(.caption)
                        
                        Text(topLabel)
                            .font(.subheadline)
                            .foregroundColor(ValetTheme.textSecondary)
                    }
                    .opacity(animateContent ? 1 : 0)
                    
                    // Shift code display with share button
                    HStack {
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                showQRCode.toggle()
                            }
                        }) {
                            HStack {
                                Text("CODE: ")
                                    .font(.caption)
                                    .foregroundColor(ValetTheme.textSecondary)
                                    
                                Text(shift.shiftCode)
                                    .font(.system(.body, design: .monospaced))
                                    .fontWeight(.bold)
                                    .kerning(1.5)
                                    .foregroundColor(ValetTheme.primary)
                                
                                Image(systemName: showQRCode ? "chevron.up" : "qrcode")
                                    .font(.caption)
                                    .foregroundColor(ValetTheme.primary)
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(ValetTheme.surfaceVariant)
                            .cornerRadius(8)
                        }
                        .scaleEffect(animateContent ? 1 : 0.8)
                        .opacity(animateContent ? 1 : 0)
                        
                        Spacer()
                        
                        Button(action: {
                            isShareSheetPresented = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.caption)
                                .foregroundColor(ValetTheme.onSurface)
                                .padding(8)
                                .background(ValetTheme.primary)
                                .cornerRadius(8)
                        }
                        .scaleEffect(animateContent ? 1 : 0.8)
                        .opacity(animateContent ? 1 : 0)
                    }
                    
                    // QR Code display (conditional)
                    if showQRCode {
                        VStack {
                            QRCodeView(code: shift.shiftCode)
                                .frame(width: 150, height: 150)
                                .padding()
                                .background(ValetTheme.surfaceVariant)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 5)
                            
                            Text("Scan to join this shift")
                                .font(.caption)
                                .foregroundColor(ValetTheme.textSecondary)
                        }
                        .padding(.vertical, 10)
                        .transition(.moveAndFade)
                    }

                    // If shift ended, show note
                    if shift.isEnded {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(ValetTheme.error)
                            
                            Text("Shift Ended")
                                .font(.subheadline)
                                .foregroundColor(ValetTheme.error)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(ValetTheme.error.opacity(0.1))
                        .cornerRadius(8)
                        .opacity(animateContent ? 1 : 0)
                    }
                }
                .padding()
                .background(ValetTheme.surfaceVariant)
                
                // Employee list with horizontal scrolling
                if !shift.employees.isEmpty {
                    VStack(alignment: .leading) {
                        Text("TEAM")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(ValetTheme.primary)
                            .padding(.horizontal)
                            .padding(.top, 12)
                            .opacity(animateContent ? 1 : 0)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(shift.employees) { employee in
                                    VStack(spacing: 4) {
                                        Circle()
                                            .fill(employee.color)
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Text(employee.name.prefix(1).uppercased())
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(.white)
                                            )
                                            .shadow(color: employee.color.opacity(0.5), radius: 4, x: 0, y: 2)
                                        
                                        Text(employee.name)
                                            .font(.caption)
                                            .foregroundColor(ValetTheme.textSecondary)
                                            .lineLimit(1)
                                    }
                                    .frame(width: 60)
                                    .scaleEffect(animateContent ? 1 : 0.8)
                                    .opacity(animateContent ? 1 : 0)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                    }
                    .background(ValetTheme.background)
                }

                // Stats summary with cars count
                HStack(spacing: 20) {
                    StatCard(
                        title: "Active",
                        value: "\(cars.filter { !$0.isReturned }.count)",
                        icon: "car.fill",
                        color: ValetTheme.primary
                    )
                    
                    StatCard(
                        title: "Returned",
                        value: "\(cars.filter { $0.isReturned }.count)",
                        icon: "checkmark.circle.fill",
                        color: ValetTheme.success
                    )
                    
                    StatCard(
                        title: "Total",
                        value: "\(cars.count)",
                        icon: "number.circle.fill",
                        color: ValetTheme.textSecondary
                    )
                }
                .padding(.vertical, 10)
                .background(ValetTheme.surfaceVariant.opacity(0.5))
                .opacity(animateContent ? 1 : 0)

                // Car List or Grid with Numbered Cars
                if cars.isEmpty {
                    // Empty state with animation
                    VStack(spacing: 15) {
                        LottieView(name: "empty-cars")
                            .frame(width: 120, height: 120)
                        
                        Text("No cars parked yet")
                            .font(.headline)
                            .foregroundColor(ValetTheme.textSecondary)
                        
                        if !shift.isEnded {
                            Text("Tap the button below to add a car")
                                .font(.subheadline)
                                .foregroundColor(ValetTheme.textSecondary.opacity(0.7))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(ValetTheme.background)
                    .opacity(animateContent ? 1 : 0)
                } else {
                    ScrollView {
                        if showAlternativeLayout {
                            // Grid layout with 3 columns
                            let columns = [GridItem(.flexible()),
                                        GridItem(.flexible()),
                                        GridItem(.flexible())]
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(Array(cars.enumerated()), id: \.element.id) { index, car in
                                    EnhancedMiniCarView(car: car, shift: shift, carIndex: index + 1)
                                        .opacity(animateContent ? 1 : 0)
                                        .scaleEffect(animateContent ? 1 : 0.9)
                                        .animation(.easeOut.delay(Double(index) * 0.05 + 0.2), value: animateContent)
                                }
                                if !shift.isEnded {
                                    EnhancedAddCarButton {
                                        showAddCarSheet.toggle()
                                    }
                                    .opacity(animateContent ? 1 : 0)
                                    .scaleEffect(animateContent ? 1 : 0.9)
                                    .animation(.easeOut.delay(Double(cars.count) * 0.05 + 0.3), value: animateContent)
                                }
                            }
                            .padding()
                        } else {
                            // List layout
                            VStack(spacing: 12) {
                                ForEach(Array(cars.enumerated()), id: \.element.id) { index, car in
                                    EnhancedCarView(car: car, shift: shift, carIndex: index + 1)
                                        .opacity(animateContent ? 1 : 0)
                                        .offset(x: animateContent ? 0 : (index % 2 == 0 ? -50 : 50))
                                        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(index) * 0.05 + 0.2), value: animateContent)
                                }
                                
                                if !shift.isEnded {
                                    // Add car button in list view
                                    Button {
                                        showAddCarSheet.toggle()
                                    } label: {
                                        HStack {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 22))
                                            Text("Add New Car")
                                                .font(.headline)
                                        }
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [ValetTheme.primary, ValetTheme.primaryVariant]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(12)
                                        .shadow(color: ValetTheme.primary.opacity(0.3), radius: 5, x: 0, y: 3)
                                    }
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                                    .opacity(animateContent ? 1 : 0)
                                    .offset(y: animateContent ? 0 : 30)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(cars.count) * 0.05 + 0.3), value: animateContent)
                                }
                            }
                            .padding()
                        }
                    }
                    .background(ValetTheme.background)
                }
                
                // Bottom action bar
                if !shift.isEnded {
                    if cars.isEmpty {
                                            VStack(spacing: 0) {
                                                HStack(spacing: 0) {
                                                    Button {
                                                        showEmployeeSheet = true
                                                    } label: {
                                                        HStack {
                                                            Image(systemName: "person.badge.plus")
                                                            Text("Add Team")
                                                        }
                                                        .font(.headline)
                                                        .foregroundColor(ValetTheme.primary)
                                                        .padding(.vertical, 16)
                                                        .frame(maxWidth: .infinity)
                                                        .background(ValetTheme.surfaceVariant)
                                                    }
                                                    .opacity(animateContent ? 1 : 0)

                                                    Button {
                                                        showAddCarSheet.toggle()
                                                    } label: {
                                                        HStack {
                                                            Image(systemName: "plus.circle.fill")
                                                            Text("Add Car")
                                                        }
                                                        .font(.headline)
                                                        .foregroundColor(.white)
                                                        .padding(.vertical, 16)
                                                        .frame(maxWidth: .infinity)
                                                        .background(ValetTheme.primaryGradient)
                                                    }
                                                    .opacity(animateContent ? 1 : 0)
                                                }
                                            }
                                        } else {
                        // Otherwise show split buttons
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                Button {
                                    showEmployeeSheet = true
                                } label: {
                                    HStack {
                                        Image(systemName: "person.badge.plus")
                                        Text("Add Team")
                                    }
                                    .font(.headline)
                                    .foregroundColor(ValetTheme.primary)
                                    .padding(.vertical, 16)
                                    .frame(maxWidth: .infinity)
                                    .background(ValetTheme.surfaceVariant)
                                }
                                .opacity(animateContent ? 1 : 0)

                                Button {
                                    showAddCarSheet.toggle()
                                } label: {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add Car")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 16)
                                    .frame(maxWidth: .infinity)
                                    .background(ValetTheme.primaryGradient)
                                }
                                .opacity(animateContent ? 1 : 0)
                            }
                            
                            // End Shift button
                            Button {
                                // Handled by gesture
                            } label: {
                                HStack {
                                    if isHoldingEndShift {
                                        Text("Ending in \(endShiftCountdown)s...")
                                    } else {
                                        Image(systemName: "stop.circle.fill")
                                        Text("End Shift")
                                    }
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity)
                                .background(
                                    pulsingRed ?
                                        LinearGradient(
                                            gradient: Gradient(colors: [ValetTheme.error, ValetTheme.error.opacity(0.8)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ) :
                                        LinearGradient(
                                            gradient: Gradient(colors: [ValetTheme.error.opacity(0.8), ValetTheme.error.opacity(0.6)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                )
                            }
                            .simultaneousGesture(
                                LongPressGesture(minimumDuration: 5.0)
                                    .onChanged { _ in
                                        if !isHoldingEndShift {
                                            isHoldingEndShift = true
                                            startEndShiftCountdown()
                                            withAnimation(Animation.easeInOut(duration: 0.6).repeatForever()) {
                                                pulsingRed = true
                                            }
                                        }
                                    }
                                    .onEnded { _ in
                                        endShiftNow()
                                    }
                            )
                            .opacity(animateContent ? 1 : 0)
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Shift Details")
                    .font(.headline)
                    .foregroundColor(ValetTheme.primary)
            }
        }
        .sheet(isPresented: $showAddCarSheet) {
            AddCarSheet(shift: shift)
                .preferredColorScheme(.dark)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showEmployeeSheet) {
            EmployeeSheet()
                .preferredColorScheme(.dark)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isShareSheetPresented) {
            // Share Sheet for iOS to share the shift code
            ShareSheetView(shiftCode: shift.shiftCode, customerName: shift.customerName)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    animateContent = true
                }
                
            }
            
        }
        .preferredColorScheme(.dark)
    }

    private func startEndShiftCountdown() {
        endShiftCountdown = 5
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            endShiftCountdown -= 1
            if endShiftCountdown <= 0 {
                timer.invalidate()
            }
        }
    }

    private func endShiftNow() {
        shiftStore.endShift(shift)
        isHoldingEndShift = false
        endShiftCountdown = 5
        pulsingRed = false
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// Extension for transition animations
extension AnyTransition {
    static var moveAndFade: AnyTransition {
        let insertion = AnyTransition.move(edge: .bottom)
            .combined(with: .opacity)
        let removal = AnyTransition.move(edge: .bottom)
            .combined(with: .opacity)
        return .asymmetric(insertion: insertion, removal: removal)
    }
}

// MARK: - Supporting Views

// Simple Lottie Animation View wrapper
struct LottieView: View {
    let name: String
    
    var body: some View {
        // This would normally use Lottie, but for now we'll just use a placeholder
        ZStack {
            Image(systemName: "car.circle")
                .font(.system(size: 60))
                .foregroundColor(ValetTheme.primary.opacity(0.3))
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(ValetTheme.primary.opacity(0.7))
                        .offset(x: 15, y: 15)
                )
        }
    }
}

// QR Code View
struct QRCodeView: View {
    let code: String
    
    var body: some View {
        Image(uiImage: generateQRCode(from: code))
            .resizable()
            .interpolation(.none)
            .scaledToFit()
            .background(Color.white)
            .cornerRadius(8)
    }
    
    // Generate QR code from string
    private func generateQRCode(from string: String) -> UIImage {
        let data = string.data(using: .ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                let context = CIContext()
                if let cgImage = context.createCGImage(output, from: output.extent) {
                    return UIImage(cgImage: cgImage)
                }
            }
        }
        
        // Fallback
        return UIImage(systemName: "qrcode") ?? UIImage()
    }
}

// Stat Card for stats summary
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(ValetTheme.textSecondary)
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
}
