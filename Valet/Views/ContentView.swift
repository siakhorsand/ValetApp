//
//  ContentView.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var shiftStore: ShiftStore
    @State private var showNewShiftSheet = false
    @State private var showJoinShiftSheet = false
    @State private var selectedShiftId: UUID?
    @State private var animateGradient = false
    @State private var animateButtons = false
    @State private var startAnimation = false
    
    // Animated particles for background effect
    let particleCount = 30

    var body: some View {
        NavigationView {
            ZStack {
                // Animated background
                ZStack {
                    // Base gradient
                    RadialGradient(
                        gradient: Gradient(colors: [
                            ValetTheme.primaryVariant.opacity(0.3),
                            ValetTheme.background
                        ]),
                        center: .center,
                        startRadius: animateGradient ? 100 : 200,
                        endRadius: animateGradient ? 600 : 400
                    )
                    .ignoresSafeArea()
                    .hueRotation(.degrees(animateGradient ? 10 : -10))
                    
                    // Accent gradient overlay
                    LinearGradient(
                        gradient: Gradient(colors: [
                            ValetTheme.background,
                            ValetTheme.background.opacity(0.9),
                            ValetTheme.primary.opacity(0.1),
                            ValetTheme.background.opacity(0.9)
                        ]),
                        startPoint: animateGradient ? .bottomLeading : .topTrailing,
                        endPoint: animateGradient ? .topTrailing : .bottomLeading
                    )
                    .ignoresSafeArea()
                    
                    // Particle effects
                    ForEach(0..<particleCount, id: \.self) { index in
                        FloatingParticle(
                            delay: Double(index) / Double(particleCount),
                            size: CGFloat.random(in: 3...6)
                        )
                    }
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 15).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                    
                    // Staggered animation for buttons
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                            startAnimation = true
                        }
                    }
                }

                // Main content
                VStack(spacing: 0) {
                    // App header section
                    VStack(spacing: 8) {
                        // Logo and title
                        ZStack {
                            // Glow effect
                            Circle()
                                .fill(ValetTheme.primary)
                                .frame(width: 90, height: 90)
                                .blur(radius: 20)
                                .opacity(0.3)
                            
                            // Icon
                            Image(systemName: "car.fill")
                                .font(.system(size: 60))
                                .foregroundColor(ValetTheme.primary)
                                .shadow(color: ValetTheme.primary.opacity(0.8), radius: 15, x: 0, y: 4)
                        }
                        .offset(y: startAnimation ? 0 : -50)
                        .opacity(startAnimation ? 1 : 0)
                        .padding(.top, 40)
                        
                        Text("VALET MANAGER")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(ValetTheme.onBackground)
                            .tracking(2)
                            .shadow(color: ValetTheme.primary.opacity(0.5), radius: 10, x: 0, y: 4)
                            .offset(y: startAnimation ? 0 : 30)
                            .opacity(startAnimation ? 1 : 0)
                        
                        // Subtle divider
                        Rectangle()
                            .frame(width: 60, height: 3)
                            .foregroundColor(ValetTheme.primary)
                            .cornerRadius(1.5)
                            .padding(.top, 8)
                            .opacity(startAnimation ? 1 : 0)
                            .scaleEffect(startAnimation ? 1 : 0.3)
                    }
                    .padding(.bottom, 50)

                    Spacer()
                    
                    // Button section with 3D floating effect
                    VStack(spacing: 18) {
                        Text("SELECT AN OPTION")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(ValetTheme.textSecondary)
                            .tracking(1.5)
                            .opacity(startAnimation ? 1 : 0)
                            .padding(.bottom, 5)
                        
                        // Start New Shift Button with shine effect
                        EnhancedMainButton(
                            title: "Start New Shift",
                            subtitle: "Create a new valet session",
                            icon: "plus.circle.fill",
                            gradient: ValetTheme.primaryGradient,
                            delay: 0.1
                        ) {
                            showNewShiftSheet = true
                        }
                        .offset(x: startAnimation ? 0 : -200)
                        
                        // Join Shift Button
                        EnhancedMainButton(
                            title: "Join Shift",
                            subtitle: "Use a 6-digit code to join",
                            icon: "person.badge.key.fill",
                            gradient: ValetTheme.accentGradient,
                            delay: 0.2
                        ) {
                            showJoinShiftSheet = true
                        }
                        .offset(x: startAnimation ? 0 : 200)
                        
                        // Active Shifts Button
                        if shiftStore.shifts.contains(where: { !$0.isEnded }) {
                            NavigationLink(destination: ActiveShiftsListView()) {
                                EnhancedMainButtonView(
                                    title: "Active Shifts",
                                    subtitle: "View ongoing valet sessions",
                                    icon: "clock.fill",
                                    color: ValetTheme.success,
                                    delay: 0.3
                                )
                            }
                            .offset(x: startAnimation ? 0 : -200)
                        }
                        
                        // Past Shifts Button
                        NavigationLink(destination: PastShiftsView()) {
                            EnhancedMainButtonView(
                                title: "Past Shifts",
                                subtitle: "Browse completed sessions",
                                icon: "archivebox.fill",
                                color: ValetTheme.textSecondary,
                                delay: 0.4
                            )
                        }
                        .offset(x: startAnimation ? 0 : 200)
                    }
                    .padding(.horizontal, 25)

                    Spacer()
                    
                    // Sync status indicator with pulsing animation
                    Group {
                        if shiftStore.isSyncing {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(ValetTheme.primary)
                                    .frame(width: 8, height: 8)
                                    .modifier(PulsingAnimation())
                                
                                Text("Syncing data...")
                                    .font(.caption)
                                    .foregroundColor(ValetTheme.textSecondary)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 15)
                            .background(
                                Capsule()
                                    .fill(ValetTheme.surfaceVariant.opacity(0.6))
                            )
                            
                        } else if let lastSync = shiftStore.lastSyncTime {
                            HStack(spacing: 5) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(ValetTheme.success)
                                    .font(.caption)
                                Text("Last synced: \(lastSync, formatter: timeFormatter)")
                                    .font(.caption)
                                    .foregroundColor(ValetTheme.textSecondary)
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(
                                Capsule()
                                    .fill(ValetTheme.surfaceVariant.opacity(0.4))
                            )
                        }
                    }
                    .padding(.bottom, 20)
                    .opacity(startAnimation ? 1 : 0)
                }
            }
            .navigationBarHidden(true)
            // Sheet for creating new shift
            .sheet(isPresented: $showNewShiftSheet) {
                NewShiftSheet { newShiftId in
                    // After creation, we can jump to that shift detail
                    selectedShiftId = newShiftId
                }
                .preferredColorScheme(.dark)
                .presentationDetents([.medium, .fraction(0.4)])
                .presentationDragIndicator(.visible)
                .background(ValetTheme.background)
            }
            // Sheet for joining a shift
            .sheet(isPresented: $showJoinShiftSheet) {
                JoinShiftView()
                .preferredColorScheme(.dark)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .background(ValetTheme.background)
            }
            // Hidden nav link to go directly to ShiftDetailView if needed
            .background(
                NavigationLink(
                    isActive: Binding(
                        get: { selectedShiftId != nil },
                        set: { if !$0 { selectedShiftId = nil } }
                    )
                ) {
                    // Destination block
                    if let id = selectedShiftId,
                       let shift = shiftStore.shifts.first(where: { $0.id == id }) {
                        ShiftDetailView(shift: shift)
                    } else {
                        EmptyView()
                    }
                } label: {
                    EmptyView()
                }
            )
            .preferredColorScheme(.dark)
        }
    }
    
    // Formatter for the last sync time
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
}

// MARK: - Supporting Views

// Enhanced main button with subtitle and flat design
struct EnhancedMainButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: LinearGradient
    let delay: Double
    let action: () -> Void
    @State private var isPressed = false
    @State private var appear = false
    
    var body: some View {
        Button(action: {
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
            action()
        }) {
            HStack(spacing: 15) {
                // Icon with simplified design
                ZStack {
                    Circle()
                        .fill(ValetTheme.surfaceVariant)
                        .frame(width: 45, height: 45)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(ValetTheme.primary)
                }
                .scaleEffect(isPressed ? 0.95 : 1)
                
                // Text content
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(ValetTheme.onSurface)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(ValetTheme.textSecondary)
                }
                
                Spacer()
                
                // Chevron with primary color
                Image(systemName: "chevron.right")
                    .foregroundColor(ValetTheme.primary)
                    .font(.subheadline)
                    .offset(x: isPressed ? -5 : 0)
                    .animation(.easeOut(duration: 0.2), value: isPressed)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(ValetTheme.surfaceVariant)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(ValetTheme.primary.opacity(0.6), lineWidth: 2)
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isPressed)
            .opacity(appear ? 1 : 0)
            .blur(radius: appear ? 0 : 10)
            .onAppear {
                withAnimation(.easeOut(duration: 0.7).delay(delay)) {
                    appear = true
                }
            }
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

// Button view for the secondary buttons
struct EnhancedMainButtonView: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let delay: Double
    @State private var isPressed = false
    @State private var appear = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 45, height: 45)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }
            .scaleEffect(isPressed ? 0.95 : 1)
            
            // Text content
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(ValetTheme.onSurface)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(ValetTheme.textSecondary)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .foregroundColor(ValetTheme.textSecondary)
                .font(.subheadline)
                .offset(x: isPressed ? -5 : 0)
                .animation(.easeOut(duration: 0.2), value: isPressed)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            ZStack {
                // Button background
                RoundedRectangle(cornerRadius: 16)
                    .fill(ValetTheme.surfaceVariant)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                
                // Top highlight
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.1),
                                .clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .mask(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.black, .clear]),
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                    )
            }
        )
        .scaleEffect(isPressed ? 0.98 : 1)
        .offset(y: isPressed ? 1 : -1)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isPressed)
        .opacity(appear ? 1 : 0)
        .blur(radius: appear ? 0 : 10)
        .onAppear {
            withAnimation(.easeOut(duration: 0.7).delay(delay)) {
                appear = true
            }
        }
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

// Floating particle for background effect
struct FloatingParticle: View {
    let delay: Double
    let size: CGFloat
    
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .fill(ValetTheme.primary.opacity(0.3))
            .frame(width: size, height: size)
            .blur(radius: 1)
            .offset(
                x: isAnimating ? CGFloat.random(in: -100...100) : CGFloat.random(in: -100...100),
                y: isAnimating ? CGFloat.random(in: -300...300) : CGFloat.random(in: -300...300)
            )
            .opacity(isAnimating ? Double.random(in: 0.2...0.6) : 0)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: Double.random(in: 15...25))
                        .repeatForever(autoreverses: true)
                        .delay(delay * 2)
                ) {
                    isAnimating = true
                }
            }
    }
}

// Pulsing animation modifier
struct PulsingAnimation: ViewModifier {
    @State private var pulsate = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(pulsate ? 1.2 : 0.8)
            .opacity(pulsate ? 1 : 0.6)
            .animation(
                Animation.easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true)
            )
            .onAppear {
                pulsate = true
            }
    }
}
