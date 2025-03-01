//
//  EnhancedCarViews.swift
//  Valet
//
//  Created by Sia Khorsand on 3/1/25.
//

import SwiftUI

// Enhanced Car View for list view with numbers
struct EnhancedCarView: View {
    @EnvironmentObject var shiftStore: ShiftStore
    let car: Car
    let shift: Shift
    let carIndex: Int
    @State private var showDetailView = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            showDetailView = true
        }) {
            HStack(spacing: 15) {
                // Car number with status indicator
                ZStack {
                    Circle()
                        .fill(car.isReturned ? ValetTheme.success : ValetTheme.primary)
                        .frame(width: 50, height: 50)
                        .shadow(color: (car.isReturned ? ValetTheme.success : ValetTheme.primary).opacity(0.3), radius: 5, x: 0, y: 3)
                    
                    Text("\(carIndex)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Return status indicator
                    if car.isReturned {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 18, height: 18)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(ValetTheme.success)
                            )
                            .offset(x: 18, y: 18)
                    }
                }
                
                // Middle: Car details
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(car.make) \(car.model)")
                        .font(.headline)
                        .foregroundColor(ValetTheme.onSurface)
                    
                    HStack(spacing: 5) {
                        Image(systemName: "number.square.fill")
                            .font(.caption2)
                            .foregroundColor(ValetTheme.primary)
                        
                        Text(car.licensePlate)
                            .font(.subheadline)
                            .foregroundColor(ValetTheme.primary)
                    }
                    
                    HStack(spacing: 5) {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                            .foregroundColor(ValetTheme.textSecondary)
                        
                        Text(car.locationParked)
                            .font(.caption)
                            .foregroundColor(ValetTheme.textSecondary)
                            .lineLimit(1)
                    }
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
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.caption2)
                                .foregroundColor(ValetTheme.success)
                            
                            Text(departureTime.toTimeString())
                                .font(.caption)
                                .foregroundColor(ValetTheme.success)
                        }
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.caption2)
                                .foregroundColor(ValetTheme.textSecondary)
                            
                            Text(car.arrivalTime.toTimeString())
                                .font(.caption)
                                .foregroundColor(ValetTheme.textSecondary)
                        }
                    }
                    
                    // Tap to view hint
                    Text("Tap to view")
                        .font(.system(size: 9))
                        .foregroundColor(ValetTheme.textSecondary.opacity(0.7))
                }
                .frame(width: 80)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(ValetTheme.surfaceVariant)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
            .scaleEffect(isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            .contentShape(Rectangle())
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 2.0)
                    .onChanged { _ in
                        isPressed = true
                    }
                    .onEnded { _ in
                        isPressed = false
                        if !car.isReturned {
                            // Haptic feedback before return
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            
                            shiftStore.returnCar(in: shift, car: car)
                        }
                    }
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = true
                        }
                    })
                    .onEnded({ _ in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = false
                        }
                    })
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetailView) {
            DetailedCarView(car: car, carIndex: carIndex)
                .preferredColorScheme(.dark)
        }
    }
}

// Enhanced Mini Car View for grid view with numbers
struct EnhancedMiniCarView: View {
    @EnvironmentObject var shiftStore: ShiftStore
    let car: Car
    let shift: Shift
    let carIndex: Int
    @State private var showDetailView = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            showDetailView = true
        }) {
            VStack(spacing: 10) {
                // Status indicator with number
                ZStack {
                    Circle()
                        .fill(car.isReturned ? ValetTheme.success : ValetTheme.primary)
                        .frame(width: 54, height: 54)
                        .shadow(color: (car.isReturned ? ValetTheme.success : ValetTheme.primary).opacity(0.3), radius: 5, x: 0, y: 3)
                    
                    Text("#\(carIndex)")
                        .font(.system(size: 18, weight: .bold))
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
                
                // Make/model (truncated)
                Text("\(car.make) \(car.model)")
                    .font(.caption2)
                    .foregroundColor(ValetTheme.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 4)
            }
            .padding(8)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(ValetTheme.surfaceVariant)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
            .overlay(
                Text("View")
                    .font(.system(size: 9))
                    .padding(.vertical, 2)
                    .padding(.horizontal, 6)
                    .background(ValetTheme.primary.opacity(0.3))
                    .cornerRadius(4)
                    .foregroundColor(ValetTheme.primary)
                    .offset(y: 45)
                    .opacity(isPressed ? 1.0 : 0.0)
            )
            .scaleEffect(isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            .contentShape(Rectangle())
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 2.0)
                    .onChanged { _ in
                        isPressed = true
                    }
                    .onEnded { _ in
                        isPressed = false
                        if !car.isReturned {
                            // Haptic feedback before return
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            
                            shiftStore.returnCar(in: shift, car: car)
                        }
                    }
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = true
                        }
                    })
                    .onEnded({ _ in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = false
                        }
                    })
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetailView) {
            DetailedCarView(car: car, carIndex: carIndex)
                .preferredColorScheme(.dark)
        }
    }
}

// Enhanced Add Car Button for grid view (unchanged)
struct EnhancedAddCarButton: View {
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    Circle()
                        .fill(ValetTheme.primaryGradient)
                        .frame(width: 54, height: 54)
                        .shadow(color: ValetTheme.primary.opacity(0.3), radius: 5, x: 0, y: 3)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text("Add Car")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(ValetTheme.primary)
                
                Text("New vehicle")
                    .font(.caption2)
                    .foregroundColor(ValetTheme.textSecondary)
            }
            .padding(8)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(ValetTheme.surfaceVariant.opacity(0.5))
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
            .scaleEffect(isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged({ _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                })
                .onEnded({ _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                })
        )
    }
}

// MARK: - Detailed Car View

// Detailed Car View shown when tapping a car
struct DetailedCarView: View {
    let car: Car
    let carIndex: Int
    @Environment(\.dismiss) var dismiss
    @State private var animateContent = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    ValetTheme.background,
                    ValetTheme.surfaceVariant.opacity(0.3),
                    ValetTheme.background
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Content
            ScrollView {
                VStack(spacing: 25) {
                    // Header with car number and status
                    VStack(spacing: 10) {
                        ZStack {
                            // Status badge
                            HStack {
                                Spacer()
                                
                                Text(car.isReturned ? "RETURNED" : "ACTIVE")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(car.isReturned ? .white : .white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(car.isReturned ? ValetTheme.success : ValetTheme.primary)
                                    .cornerRadius(20)
                                    .offset(y: -10)
                                    .scaleEffect(animateContent ? 1 : 0.7)
                                    .opacity(animateContent ? 1 : 0)
                            }
                            .padding(.trailing)
                            
                            // Car number
                            VStack(spacing: 5) {
                                Text("CAR")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(ValetTheme.textSecondary)
                                
                                Text("#\(carIndex)")
                                    .font(.system(size: 50, weight: .bold))
                                    .foregroundColor(car.isReturned ? ValetTheme.success : ValetTheme.primary)
                                    .frame(width: 90, height: 90)
                                    .background(
                                        ZStack {
                                            Circle()
                                                .fill(car.isReturned ? ValetTheme.success.opacity(0.1) : ValetTheme.primary.opacity(0.1))
                                                .frame(width: 85)
                                            
                                            Circle()
                                                .strokeBorder(
                                                    car.isReturned ? ValetTheme.success.opacity(0.3) : ValetTheme.primary.opacity(0.3),
                                                    lineWidth: 3
                                                )
                                                .frame(width: 90)
                                        }
                                    )
                                    .scaleEffect(animateContent ? 1 : 0.8)
                            }
                            .offset(y: -10)
                        }
                        
                        // Make and Model
                        Text("\(car.make) \(car.model)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(ValetTheme.onSurface)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .offset(y: animateContent ? 0 : 20)
                            .opacity(animateContent ? 1 : 0)
                    }
                    .padding(.top, 20)
                    
                    // Car photo or icon
                    Group {
                        if let photo = car.photo {
                            Image(uiImage: photo)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(16)
                                .padding(.horizontal)
                                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                        } else {
                            // Just show car information block with no icon
                            HStack(spacing: 15) {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Make & Model")
                                        .font(.caption)
                                        .foregroundColor(ValetTheme.textSecondary)
                                        
                                    Text("\(car.make) \(car.model)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(ValetTheme.onSurface)
                                    
                                    Text("Color: \(car.color)")
                                        .font(.body)
                                        .foregroundColor(ValetTheme.primary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Car number badge
                                ZStack {
                                    Circle()
                                        .fill(car.isReturned ? ValetTheme.success.opacity(0.2) : ValetTheme.primary.opacity(0.2))
                                        .frame(width: 60, height: 60)
                                    
                                    Text("#\(carIndex)")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(car.isReturned ? ValetTheme.success : ValetTheme.primary)
                                }
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(ValetTheme.surfaceVariant)
                                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                            )
                            .padding(.horizontal)
                        }
                    }
                    .offset(y: animateContent ? 0 : 30)
                    .opacity(animateContent ? 1 : 0)
                    
                    // License plate
                    VStack(spacing: 5) {
                        Text("LICENSE PLATE")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(ValetTheme.textSecondary)
                        
                        Text(car.licensePlate)
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .kerning(2)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(ValetTheme.surfaceVariant)
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(ValetTheme.primary.opacity(0.5), lineWidth: 2)
                            )
                    }
                    .offset(y: animateContent ? 0 : 40)
                    .opacity(animateContent ? 1 : 0)
                    
                    // Car details
                    VStack(spacing: 16) {
                        // Location
                        DetailField(
                            title: "LOCATION PARKED",
                            value: car.locationParked,
                            icon: "location.fill",
                            delay: 0.1
                        )
                        
                        // Time details
                        DetailField(
                            title: "ARRIVAL TIME",
                            value: formatDateTime(car.arrivalTime),
                            icon: "clock.fill",
                            delay: 0.2
                        )
                        
                        if car.isReturned, let departureTime = car.departureTime {
                            DetailField(
                                title: "DEPARTURE TIME",
                                value: formatDateTime(departureTime),
                                icon: "clock.arrow.circlepath",
                                color: ValetTheme.success,
                                delay: 0.3
                            )
                            
                            // Duration parked
                            DetailField(
                                title: "DURATION PARKED",
                                value: calculateDuration(from: car.arrivalTime, to: departureTime),
                                icon: "hourglass",
                                color: ValetTheme.secondary,
                                delay: 0.4
                            )
                        }
                        
                        // Parked by
                        if let employee = car.parkedBy {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(ValetTheme.primary)
                                    
                                    Text("PARKED BY")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(ValetTheme.textSecondary)
                                }
                                
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(employee.color)
                                        .frame(width: 36, height: 36)
                                        .overlay(
                                            Text(employee.name.prefix(1).uppercased())
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                        )
                                    
                                    Text(employee.name)
                                        .font(.headline)
                                        .foregroundColor(ValetTheme.onSurface)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(ValetTheme.surfaceVariant)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(employee.color.opacity(0.3), lineWidth: 2)
                                )
                            }
                            .padding(.horizontal)
                            .offset(y: animateContent ? 0 : 50 + 0.5 * 10)
                            .opacity(animateContent ? 1 : 0)
                        }
                    }
                    .padding(.top, 10)
                    
                    Spacer(minLength: 50)
                }
                .padding(.bottom, 20)
            }
            
            // Close button
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(ValetTheme.onSurface)
                            .padding(10)
                            .background(ValetTheme.surfaceVariant)
                            .clipShape(Circle())
                    }
                    .padding(.leading)
                    
                    Spacer()
                }
                .padding(.top, 15)
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateContent = true
            }
        }
    }
    
    // Format date and time
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Calculate duration between dates
    private func calculateDuration(from startDate: Date, to endDate: Date) -> String {
        let components = Calendar.current.dateComponents([.hour, .minute], from: startDate, to: endDate)
        
        if let hours = components.hour, let minutes = components.minute {
            if hours > 0 {
                return "\(hours) hr \(minutes) min"
            } else {
                return "\(minutes) minutes"
            }
        }
        
        return "Unknown duration"
    }
}

// Detail field for car information
struct DetailField: View {
    let title: String
    let value: String
    let icon: String
    var color: Color = ValetTheme.primary
    var delay: Double = 0
    @State private var appear = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(ValetTheme.textSecondary)
            }
            
            Text(value)
                .font(.headline)
                .foregroundColor(ValetTheme.onSurface)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ValetTheme.surfaceVariant)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 2)
                )
        }
        .padding(.horizontal)
        .offset(y: appear ? 0 : 50)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1 + delay)) {
                appear = true
            }
        }
    }
}

// MARK: - Extensions

extension Date {
    // Format to something like "6:30 PM"
    func toTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: self)
    }
}
