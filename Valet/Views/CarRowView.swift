//
//  CarRowView.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//

import SwiftUI

struct CarRowView: View {
    @EnvironmentObject var shiftStore: ShiftStore
    let shift: Shift
    let car: Car

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("License Plate: \(car.licensePlate)")
                    .font(.headline)
                Text("Returned: \(car.isReturned ? "Yes" : "No")")
                    .font(.subheadline)
            }
            Spacer()
            // Return button if not returned
            if !car.isReturned && !shift.isEnded {
                Button("Return") {
                    shiftStore.returnCar(in: shift, car: car)
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

struct CarRowView_Previews: PreviewProvider {
    static var previews: some View {
        let previewShift = Shift(customerName: "Test Customer", address: "123 Test St")
        let previewCar = Car(
            licensePlate: "ABC123",
            make: "Toyota",
            model: "Corolla",
            color: "Silver",
            locationParked: "Front Row"
        )
        
        return CarRowView(shift: previewShift, car: previewCar)
            .environmentObject(ShiftStore())
            .previewLayout(.sizeThatFits)
    }
}
