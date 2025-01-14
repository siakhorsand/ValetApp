//
//  NewShiftSheet.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//

import SwiftUI

// NewShiftSheet.swift
import SwiftUI

struct NewShiftSheet: View {
    @EnvironmentObject var shiftStore: ShiftStore
    @Environment(\.dismiss) var dismiss

    @State private var customerName = ""
    @State private var address = ""

    // Callback: pass the new shift ID back to ContentView
    let onShiftCreated: (UUID) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Start a New Shift")
                .font(.headline)
                .padding(.top, 20)

            VStack(spacing: 15) {
                TextField("Customer Name", text: $customerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Address", text: $address)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            .frame(maxWidth: 300)
            .padding()

            Spacer()

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(8)

                Button("Create Shift") {
                    guard !customerName.isEmpty, !address.isEmpty else { return }
                    let newShift = shiftStore.startShift(customerName: customerName, address: address)
                    onShiftCreated(newShift.id)
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(!customerName.isEmpty && !address.isEmpty ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .frame(height: 300)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.8))
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding()
    }
}
