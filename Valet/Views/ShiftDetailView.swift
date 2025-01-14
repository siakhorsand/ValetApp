//
//  ShiftDetailView.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//

// ShiftDetailView.swift
import SwiftUI

struct ShiftDetailView: View {
    @EnvironmentObject var shiftStore: ShiftStore
    let shift: Shift

    @State private var showAddCarSheet = false
    @State private var showEmployeeSheet = false

    // End shift hold
    @State private var isHoldingEndShift = false
    @State private var endShiftCountdown = 5
    @State private var pulsingRed = false

    var cars: [Car] {
        shiftStore.shifts.first(where: { $0.id == shift.id })?.cars ?? []
    }

    var body: some View {
        VStack {
            Text("\(shift.customerName) - \(shift.address)")
                .font(.title2)
                .padding(.top, 10)

            if shift.isEnded {
                Text("Shift Ended")
                    .foregroundColor(.red)
            }

            // Car List
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(cars) { car in
                        CarButtonView(car: car, shift: shift)
                    }
                    if !shift.isEnded {
                        Button {
                            showAddCarSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Car")
                            }
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(radius: 4)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }

            if !shift.isEnded {
                HStack {
                    Button("Add Employee") {
                        showEmployeeSheet = true
                    }
                    .buttonStyle(.borderedProminent)

                    // End Shift Button with 5s hold/pulsate
                    Button {
                        // The gesture below will handle it
                    } label: {
                        Text(isHoldingEndShift ? "Ending in \(endShiftCountdown)s..." : "End Shift")
                            .fontWeight(.semibold)
                            .padding()
                            .frame(width: 120, height: 44)
                            .background(pulsingRed ? Color.red : Color.red.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .shadow(radius: 4)
                            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulsingRed)
                    }
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 5.0)
                            .onChanged { _ in
                                if !isHoldingEndShift {
                                    isHoldingEndShift = true
                                    startEndShiftCountdown()
                                    pulsingRed = true
                                }
                            }
                            .onEnded { _ in
                                endShiftNow()
                            }
                    )
                }
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddCarSheet) {
            AddCarSheet(shift: shift)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .background(.ultraThinMaterial)
        }
        .sheet(isPresented: $showEmployeeSheet) {
            EmployeeSheet()
        }
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
    }
}
