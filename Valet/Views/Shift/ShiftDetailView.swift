//
//  ShiftDetailView.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//

import SwiftUI

struct ShiftDetailView: View {
    @EnvironmentObject var shiftStore: ShiftStore
    @EnvironmentObject var userManager: UserManager
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
                // Header Card with slide-in animation - more compact
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
                
                // Employee list - COMPACT VERSION with team chips
                if !shift.employees.isEmpty {
                    HStack {
                        // Team label
                        Text("TEAM:")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(ValetTheme.primary.opacity(0.8))
                            .padding(.leading)
                        
                        // Horizontal scroll for team members - more compact with chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(shift.employees) { employee in
                                    // Compact employee chip
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(employee.color.opacity(0.7))
                                            .frame(width: 8, height: 8)
                                        
                                        Text(employee.name)
                                            .font(.caption2)
                                            .foregroundColor(ValetTheme.textSecondary)
                                    }
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(ValetTheme.surfaceVariant.opacity(0.7))
                                    .cornerRadius(4)
                                    .scaleEffect(animateContent ? 1 : 0.8)
                                    .opacity(animateContent ? 1 : 0)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .background(ValetTheme.background)
                }

                // Stats summary with cars count
                HStack(spacing: 20) {
                    StatCard(
                        title: "Active",
                        value: "\(cars.filter { !$0.isReturned }.count)",
                        icon: "car.fill",
                        color: ValetTheme.primary.opacity(0.9)
                    )
                    
                    StatCard(
                        title: "Returned",
                        value: "\(cars.filter { $0.isReturned }.count)",
                        icon: "checkmark.fill",
                        color: ValetTheme.success.opacity(0.9)
                    )
                    
                    StatCard(
                        title: "Total",
                        value: "\(cars.count)",
                        icon: "number.fill",
                        color: ValetTheme.textSecondary.opacity(0.8)
                    )
                }
                .padding(.vertical, 8)
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
                            // Grid layout with 3 columns - now using the updated sleeker components
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
                            // List layout - now using the updated sleeker components
                            VStack(spacing: 10) {
                                ForEach(Array(cars.enumerated()), id: \.element.id) { index, car in
                                    EnhancedCarView(car: car, shift: shift, carIndex: index + 1)
                                        .opacity(animateContent ? 1 : 0)
                                        .offset(x: animateContent ? 0 : (index % 2 == 0 ? -50 : 50))
                                        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(index) * 0.05 + 0.2), value: animateContent)
                                }
                                
                                if !shift.isEnded {
                                    // Add car button in list view - cleaner style
                                    Button {
                                        showAddCarSheet.toggle()
                                    } label: {
                                        HStack {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 18))
                                            Text("Add New Car")
                                                .font(.headline)
                                        }
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    ValetTheme.primary.opacity(0.8),
                                                    ValetTheme.primaryVariant.opacity(0.8)
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(10)
                                        .shadow(color: ValetTheme.primary.opacity(0.2), radius: 4, x: 0, y: 2)
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

// Stat Card for stats summary - updated for a cleaner look
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(color)
            
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundColor(color.opacity(0.7))
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(ValetTheme.textSecondary.opacity(0.9))
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#if DEBUG
struct ShiftDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let shiftStore = ShiftStore(withDemoData: true)
        let shift = shiftStore.shifts.first!
        
        return NavigationView {
            ShiftDetailView(shift: shift)
                .environmentObject(shiftStore)
                .environmentObject(UserManager.shared)
        }
        .preferredColorScheme(.dark)
    }
}
#endif
