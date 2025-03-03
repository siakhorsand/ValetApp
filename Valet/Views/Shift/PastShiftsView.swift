//
//  PastShiftsView.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//

import SwiftUI

struct PastShiftsView: View {
    @EnvironmentObject var shiftStore: ShiftStore
    @State private var selectedShift: Shift?
    @State private var animateList = false

    var body: some View {
        ZStack {
            // Background
            ValetTheme.background
                .ignoresSafeArea()
            
            // Content
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Past Shifts")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(ValetTheme.primary)
                    
                    Spacer()
                }
                .padding()
                .background(ValetTheme.surfaceVariant)
                
                if shiftStore.shifts.filter({ $0.isEnded }).isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "archivebox")
                            .font(.system(size: 60))
                            .foregroundColor(ValetTheme.textSecondary.opacity(0.5))
                        
                        Text("No Past Shifts")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(ValetTheme.textSecondary)
                        
                        Text("Past shifts will appear here when completed")
                            .font(.subheadline)
                            .foregroundColor(ValetTheme.textSecondary.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // List of past shifts
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(shiftStore.shifts.filter { $0.isEnded }.sorted(by: { $0.endTime ?? Date() > $1.endTime ?? Date() })) { shift in
                                NavigationLink(destination: ShiftDetailView(shift: shift)) {
                                    PastShiftCard(shift: shift)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .offset(x: animateList ? 0 : -50)
                                .opacity(animateList ? 1 : 0)
                                .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(Double(shiftStore.shifts.firstIndex(where: { $0.id == shift.id }) ?? 0) * 0.05), value: animateList)
                            }
                        }
                        .padding()
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation {
                animateList = true
            }
        }
        .onDisappear {
            animateList = false
        }
    }
}

// Card for past shifts
struct PastShiftCard: View {
    let shift: Shift
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with customer and date
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(shift.customerName)
                        .font(.headline)
                        .foregroundColor(ValetTheme.onSurface)
                    
                    if let endTime = shift.endTime {
                        Text(formatDate(endTime))
                            .font(.subheadline)
                            .foregroundColor(ValetTheme.textSecondary)
                    }
                }
                
                Spacer()
                
                // Status badge
                Text("COMPLETED")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(ValetTheme.success.opacity(0.2))
                    .foregroundColor(ValetTheme.success)
                    .cornerRadius(4)
            }
            
            Divider()
                .background(ValetTheme.primary.opacity(0.3))
            
            // Stats
            HStack(spacing: 20) {
                StatItem(value: "\(shift.cars.count)", label: "Cars", icon: "car.fill")
                
                StatItem(
                    value: "\(shift.cars.filter { $0.isReturned }.count)",
                    label: "Returned",
                    icon: "checkmark.circle.fill",
                    color: ValetTheme.success
                )
                
                if let endTime = shift.endTime, let duration = calculateDuration(from: shift.startTime, to: endTime) {
                    StatItem(value: duration, label: "Duration", icon: "clock.fill", color: ValetTheme.primary)
                }
                
                Spacer()
                
                // Team
                HStack {
                    ForEach(0..<min(3, shift.employees.count), id: \.self) { index in
                        Circle()
                            .fill(shift.employees[index].color)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Text(shift.employees[index].name.prefix(1).uppercased())
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                            .offset(x: -CGFloat(index * 12))
                    }
                    
                    if shift.employees.count > 3 {
                        Circle()
                            .fill(ValetTheme.surfaceVariant)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Text("+\(shift.employees.count - 3)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(ValetTheme.textSecondary)
                            )
                            .offset(x: -36)
                    }
                }
                .padding(.trailing, 8)
            }
            
            // Navigation hint
            HStack {
                Spacer()
                
                HStack(spacing: 4) {
                    Text("View Details")
                        .font(.caption)
                        .foregroundColor(ValetTheme.primary.opacity(0.7))
                    
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundColor(ValetTheme.primary.opacity(0.7))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ValetTheme.surfaceVariant)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    // Format date to "Mar 3, 2025 at 2:30 PM"
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Calculate duration for display
    private func calculateDuration(from startDate: Date, to endDate: Date) -> String? {
        let components = Calendar.current.dateComponents([.hour, .minute], from: startDate, to: endDate)
        
        if let hours = components.hour, let minutes = components.minute {
            if hours > 0 {
                return "\(hours)h \(minutes)m"
            } else {
                return "\(minutes)m"
            }
        }
        
        return nil
    }
}

// Stat item for past shift card
struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    var color: Color = ValetTheme.textSecondary
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundColor(color)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(ValetTheme.textSecondary.opacity(0.8))
        }
    }
}
