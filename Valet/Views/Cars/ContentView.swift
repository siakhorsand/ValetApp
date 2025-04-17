//
//  ContentView.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var shiftStore: ShiftStore
    @EnvironmentObject var userManager: UserManager
    
    @State private var showNewShiftSheet = false
    @State private var showJoinShiftSheet = false
    @State private var showProfileSheet = false
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
                    // Profile button in top right
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            showProfileSheet = true
                        }) {
                            HStack(spacing: 8) {
                                // Profile text
                                if let user = userManager.currentUser {
                                    Text(user.name)
                                        .font(.subheadline)
                                        .foregroundColor(ValetTheme.onBackground)
                                }
                                
                                // Avatar circle
                                ZStack {
                                    Circle()
                                        .fill(ValetTheme.primary)
                                        .frame(width: 36, height: 36)
                                    
                                    Text(userManager.currentUser?.name.prefix(1).uppercased() ?? "U")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(8)
                            .background(
                                Capsule()
                                    .fill(ValetTheme.surfaceVariant.opacity(0.7))
                            )
                        }
                        .padding(.top, 20)
                        .padding(.trailing, 20)
                    }
                    
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
                        .padding(.top, 20)
                        
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
            // Floating modal for creating new shift
            .overlay {
                if showNewShiftSheet {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                showNewShiftSheet = false
                            }
                        }
                    
                    NewShiftSheet(
                        onShiftCreated: { newShiftId in
                            // After creation, we can jump to that shift detail
                            selectedShiftId = newShiftId
                        },
                        onCancel: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                showNewShiftSheet = false
                            }
                        }
                    )
                    .preferredColorScheme(.dark)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showNewShiftSheet)
            
            // Sheet for joining a shift
            .sheet(isPresented: $showJoinShiftSheet) {
                JoinShiftView()
                .preferredColorScheme(.dark)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .background(ValetTheme.background)
            }
            
            // Sheet for profile
            .sheet(isPresented: $showProfileSheet) {
                ProfileView()
                .preferredColorScheme(.dark)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .background(ValetTheme.background)
            }
            
            // Hidden nav link to go directly to ShiftDetailView if needed
            .background(
                Group {
                    if #available(iOS 16.0, *) {
                        NavigationLink(value: selectedShiftId) {
                            EmptyView()
                        }
                        .navigationDestination(for: UUID?.self) { id in
                            if let id = id,
                               let shift = shiftStore.shifts.first(where: { $0.id == id }) {
                                ShiftDetailView(shift: shift)
                            }
                        }
                    } else {
                        // Fallback for iOS 15 and earlier
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
                    }
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
