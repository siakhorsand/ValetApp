//
//  ShiftListView.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//

import SwiftUI

struct ShiftListView: View {
    @EnvironmentObject var shiftStore: ShiftStore
    @State private var nameText = ""
    @State private var addressText = ""

    var body: some View {
        VStack {
            List {
                Section(header: Text("Active Shifts")) {
                    // Use an ID if needed: (shiftStore.shifts.filter { !$0.isEnded }, id: \.id)
                    ForEach(shiftStore.shifts.filter { !$0.isEnded }) { shift in
                        NavigationLink(destination: ShiftDetailView(shift: shift)) {
                            VStack(alignment: .leading) {
                                Text(shift.customerName)
                                    .font(.headline)
                                Text("Cars: \(shift.cars.count)")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                Section(header: Text("Past Shifts")) {
                    ForEach(shiftStore.shifts.filter { $0.isEnded }) { shift in
                        NavigationLink(destination: ShiftDetailView(shift: shift)) {
                            VStack(alignment: .leading) {
                                Text(shift.customerName)
                                    .font(.headline)
                                Text("Ended on: \(shift.endTime?.formatted() ?? "N/A")")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }

            // Start New Shift
            VStack {
                TextField("Enter customer name", text: $nameText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Enter address", text: $addressText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Start Shift") {
                    guard !nameText.isEmpty, !addressText.isEmpty else { return }
                       
                    // This captures the newly created shift
                    _ = shiftStore.startShift(customerName: nameText, address: addressText)
                    nameText = ""
                    addressText = ""
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}
struct ShiftListView_Previews: PreviewProvider {
    static var previews: some View {
        ShiftListView()
            .environmentObject(ShiftStore())
    }
}
