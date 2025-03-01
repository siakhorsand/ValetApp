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
            ValetTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Card
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

                        Spacer()

                        // Toggle layout button
                        Button(action: {
                            showAlternativeLayout.toggle()
                        }) {
                            Image(systemName: showAlternativeLayout ? "list.bullet" : "rectangle.grid.2x2")
                                .font(.title3)
                                .foregroundColor(ValetTheme.primary)
                                .padding(8)
                                .background(ValetTheme.surfaceVariant)
                                .cornerRadius(8)
                        }
                    }

                    // Address and time
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .foregroundColor(ValetTheme.textSecondary)
                            .font(.caption)
                        
                        Text(topLabel)
                            .font(.subheadline)
                            .foregroundColor(ValetTheme.textSecondary)
                    }
                    
                    // Shift code display with share button
                    HStack {
                        Button(action: {
                            showQRCode.toggle()
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
                    }
                    
                    // QR Code display (conditional)
                    if showQRCode {
                        VStack {
                            QRCodeView(code: shift.shiftCode)
                                .frame(width: 150, height: 150)
                                .padding()
                                .background(ValetTheme.surfaceVariant)
                                .cornerRadius(12)
                            
                            Text("Scan to join this shift")
                                .font(.caption)
                                .foregroundColor(ValetTheme.textSecondary)
                        }
                        .padding(.vertical, 10)
                        .transition(.opacity)
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
                    }
                }
                .padding()
                .background(ValetTheme.surfaceVariant)
                
                // Employee list
                if !shift.employees.isEmpty {
                    VStack(alignment: .leading) {
                        Text("TEAM")
                            .font(.caption)
                            .foregroundColor(ValetTheme.textSecondary)
                            .padding(.horizontal)
                            .padding(.top, 12)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(shift.employees) { employee in
                                    VStack(spacing: 4) {
                                        Circle()
                                            .fill(employee.color)
                                            .frame(width: 36, height: 36)
                                            .overlay(
                                                Text(employee.name.prefix(1).uppercased())
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(.white)
                                            )
                                        
                                        Text(employee.name)
                                            .font(.caption)
                                            .foregroundColor(ValetTheme.textSecondary)
                                            .lineLimit(1)
                                    }
                                    .frame(width: 60)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                    }
                    .background(ValetTheme.background)
                }

                // Stats summary
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

                // Car List or Grid
                if cars.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "car")
                            .font(.system(size: 50))
                            .foregroundColor(ValetTheme.textSecondary.opacity(0.3))
                        
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
                } else {
                    ScrollView {
                        if showAlternativeLayout {
                            // Grid layout with 3 columns
                            let columns = [GridItem(.flexible()),
                                        GridItem(.flexible()),
                                        GridItem(.flexible())]
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(cars) { car in
                                    EnhancedMiniCarView(car: car, shift: shift)
                                }
                                if !shift.isEnded {
                                    EnhancedAddCarButton {
                                        showAddCarSheet.toggle()
                                    }
                                }
                            }
                            .padding()
                        } else {
                            // List layout
                            VStack(spacing: 12) {
                                ForEach(cars) { car in
                                    EnhancedCarView(car: car, shift: shift)
                                }
                            }
                            .padding()
                        }
                    }
                    .background(ValetTheme.background)
                }
                
                // Bottom action bar
                if !shift.isEnded {
                    // If no cars, show single "Add Car" button
                    if cars.isEmpty {
                        Button {
                            showAddCarSheet.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Car")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(ValetTheme.primaryGradient)
                            .cornerRadius(0)
                        }
                    } else {
                        // Otherwise show split buttons
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

// MARK: - Supporting Views

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

// Enhanced Car View for list view
struct EnhancedCarView: View {
    @EnvironmentObject var shiftStore: ShiftStore
    let car: Car
    let shift: Shift
    
    var body: some View {
        HStack(spacing: 15) {
            // Left side: Car icon or status indicator
            ZStack {
                Circle()
                    .fill(car.isReturned ? ValetTheme.success : ValetTheme.primary)
                    .frame(width: 50, height: 50)
                
                Image(systemName: car.isReturned ? "checkmark" : "car.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            
            // Middle: Car details
            VStack(alignment: .leading, spacing: 4) {
                Text("\(car.make) \(car.model)")
                    .font(.headline)
                    .foregroundColor(ValetTheme.onSurface)
                
                Text(car.licensePlate)
                    .font(.subheadline)
                    .foregroundColor(ValetTheme.primary)
                
                Text(car.locationParked)
                    .font(.caption)
                    .foregroundColor(ValetTheme.textSecondary)
            }
            
            Spacer()
            
            // Right side: Employee indicator & time
            VStack(alignment: .trailing, spacing: 4) {
                if let employee = car.parkedBy {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(employee.color)
                            .frame(width: 10, height: 10)
                        
                        Text(employee.name)
                            .font(.caption)
                            .foregroundColor(ValetTheme.textSecondary)
                    }
                }
                
                // Time display
                if car.isReturned, let departureTime = car.departureTime {
                    Text(departureTime.toHourString())
                        .font(.caption)
                        .foregroundColor(ValetTheme.success)
                } else {
                    Text(car.arrivalTime.toHourString())
                        .font(.caption)
                        .foregroundColor(ValetTheme.textSecondary)
                }
            }
            .frame(width: 80)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ValetTheme.surfaceVariant)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: 2.0) {
            if !car.isReturned {
                // Haptic feedback before return
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                shiftStore.returnCar(in: shift, car: car)
            }
        }
    }
}

// Enhanced Mini Car View for grid view
struct EnhancedMiniCarView: View {
    @EnvironmentObject var shiftStore: ShiftStore
    let car: Car
    let shift: Shift
    
    var body: some View {
        VStack(spacing: 8) {
            // Status indicator
            ZStack {
                Circle()
                    .fill(car.isReturned ? ValetTheme.success : ValetTheme.primary)
                    .frame(width: 48, height: 48)
                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
                
                Image(systemName: car.isReturned ? "checkmark" : "car.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                
                // Employee indicator dot
                if let employee = car.parkedBy {
                    Circle()
                        .fill(employee.color)
                        .frame(width: 15, height: 15)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .offset(x: 20, y: -20)
                }
            }
            
            // License plate
            Text(car.licensePlate)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(ValetTheme.onSurface)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 4)
        }
        .padding(8)
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ValetTheme.surfaceVariant)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: 2.0) {
            if !car.isReturned {
                // Haptic feedback before return
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                shiftStore.returnCar(in: shift, car: car)
            }
        }
    }
}

// Enhanced Add Car Button for grid view
struct EnhancedAddCarButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    Circle()
                        .fill(ValetTheme.primaryGradient)
                        .frame(width: 48, height: 48)
                        .shadow(color: ValetTheme.primary.opacity(0.3), radius: 3, x: 0, y: 2)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text("Add Car")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(ValetTheme.primary)
            }
            .padding(8)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(ValetTheme.surfaceVariant.opacity(0.5))
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
        }
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
