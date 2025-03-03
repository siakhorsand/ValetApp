//
//  CarButtonView.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//

// CarButtonView.swift
import SwiftUI

struct CarButtonView: View {
    @EnvironmentObject var shiftStore: ShiftStore
    let car: Car
    let shift: Shift

    var body: some View {
        let backgroundColor = car.isReturned ? Color.black : Color.gray
        VStack(alignment: .leading) {
            HStack {
                Text("\(car.make) \(car.model) - \(car.licensePlate)")
                    .foregroundColor(.white)
                Spacer()
                if let employee = car.parkedBy {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(employee.color)
                        .frame(width: 10, height: 10)
                    Text(employee.name)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .cornerRadius(10)
        .shadow(radius: 4)
        .onLongPressGesture(minimumDuration: 3.0) {
            if !car.isReturned {
                shiftStore.returnCar(in: shift, car: car)
            }
        }
    }
}
