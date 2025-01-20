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
    // Using your example "17th Park St. @ 6PM"
    // We'll do something like: "F. LastName @ 6 PM" or custom logic
    var topLabel: String {
        // "AbbreviatedName's Address @ 6 PM"
        // or just do address + time. Adjust to your exact preference:
        // Example: "17th Park St. @ 6 PM"
        "\(shift.address) @ \(roundedStartTimeString)"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top Section
            HStack {
                Text("\(abbreviatedCustomerName)")
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()

                // Toggle layout button
                Button(action: {
                    showAlternativeLayout.toggle()
                }) {
                    Image(systemName: "rectangle.grid.2x2")
                        .font(.title2)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)

            // Subtitle below name: e.g. "17th Park St. @ 6PM"
            Text(topLabel)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 10)

            // If shift ended, small note
            if shift.isEnded {
                Text("Shift Ended")
                    .foregroundColor(.red)
                    .padding(.bottom, 10)
            }

            // Car List or Grid
            ScrollView {
                if showAlternativeLayout {
                    // Grid with 3 or 4 columns
                    // We'll do 3 columns for phones, 4 for bigger widths
                    let columns = [GridItem(.flexible()),
                                   GridItem(.flexible()),
                                   GridItem(.flexible())]
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(cars) { car in
                            // Only show color if employee is set
                            MiniCarButtonView(car: car, shift: shift)
                        }
                        if !shift.isEnded {
                            AddCarGridButton {
                                showAddCarSheet.toggle()
                            }
                        }
                    }
                    .padding()
                } else {
                    // Original single-column layout
                    VStack(spacing: 12) {
                        ForEach(cars) { car in
                            CarButtonView(car: car, shift: shift)
                        }
                        if !shift.isEnded {
                            // Prettier "Add Car" button
                            Button {
                                showAddCarSheet.toggle()
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Car")
                                }
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .cornerRadius(10)
                                .shadow(radius: 5)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
            }

            // If not ended, show bottom bar with Add Employee & End Shift
            if !shift.isEnded {
                HStack(spacing: 0) {
                    Button("Add Employee") {
                        showEmployeeSheet = true
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.blue)
                    .cornerRadius(0)

                    Button {
                        // Handled by gesture
                    } label: {
                        Text(isHoldingEndShift ? "Ending in \(endShiftCountdown)s..." : "End Shift")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(pulsingRed ? Color.red : Color.red.opacity(0.7))
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
                .frame(height: 50)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddCarSheet) {
            AddCarSheet(shift: shift)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
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
struct ShiftDetailView_Previews: PreviewProvider {
    static var previews : some View{
        Car(id : UUID(), licensePlate: <#T##String#>, make: <#T##String#>, model: <#T##String#>, color: <#T##String#>, locationParked: String)
    }
}
