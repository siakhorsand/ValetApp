//
//  ActiveShiftsListView.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//

import SwiftUI

struct ActiveShiftsListView: View {
    @EnvironmentObject var shiftStore: ShiftStore

    var body: some View {
        List {
            ForEach(shiftStore.shifts.filter { !$0.isEnded }) { shift in
                NavigationLink(destination: ShiftDetailView(shift: shift)) {
                    VStack(alignment: .leading) {
                        Text(shift.customerName)
                            .font(.headline)
                        Text("Address: \(shift.address)")
                            .font(.subheadline)
                    }
                }
            }
        }
        .navigationTitle("Active Shifts")
    }
}
