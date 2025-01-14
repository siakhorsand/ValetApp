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
    @State private var selectedShiftId: UUID?

    var body: some View {
        NavigationView {
            ZStack {
                // Dual-tone background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 30) {
                    Text("Valet Manager")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 60)

                    Spacer()

                    Button(action: {
                        showNewShiftSheet = true
                    }) {
                        Text("Start New Shift")
                            .font(.title3).bold()
                            .padding()
                            .frame(width: 250, height: 50)
                            .background(Color.white.opacity(0.9))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }

                    // Active Shifts button if any shifts are still open
                    if shiftStore.shifts.contains(where: { !$0.isEnded }) {
                        NavigationLink(destination: ActiveShiftsListView()) {
                            Text("Active Shifts")
                                .font(.title3).bold()
                                .padding()
                                .frame(width: 250, height: 50)
                                .background(Color.white.opacity(0.9))
                                .foregroundColor(.green)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        }
                    }

                    NavigationLink(destination: PastShiftsView()) {
                        Text("Past Shifts")
                            .font(.title3).bold()
                            .padding()
                            .frame(width: 250, height: 50)
                            .background(Color.white.opacity(0.9))
                            .foregroundColor(.gray)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }

                    Spacer()
                }
            }
            .navigationBarHidden(true)
            // Sheet for creating new shift
            .sheet(isPresented: $showNewShiftSheet) {
                NewShiftSheet { newShiftId in
                    // After creation, we can jump to that shift detail
                    selectedShiftId = newShiftId
                }
                // Make it floating, with smaller height if you like
                .presentationDetents([.medium, .fraction(0.4)]) // example
                .presentationDragIndicator(.visible)
                .background(.ultraThinMaterial)
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
        }
    }
}
