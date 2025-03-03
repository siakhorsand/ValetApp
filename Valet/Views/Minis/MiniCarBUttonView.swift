//
//  MiniCarBUttonView.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//
import Foundation
import SwiftUI
struct MiniCarButtonView: View {
    @EnvironmentObject var shiftStore: ShiftStore
    let car: Car
    let shift: Shift

    var body: some View {
        let backgroundColor = car.isReturned ? Color.black : Color.gray
        ZStack {
            // Wide rectangle
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
                .shadow(radius: 3)
            // If there's an employee color, show a circle or rectangle
            if let employee = car.parkedBy {
                Circle()
                    .fill(employee.color)
                    .frame(width: 20, height: 20)
            } else {
                Image(systemName: "questionmark")
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(height: 70)
        .onLongPressGesture(minimumDuration: 3.0) {
            if !car.isReturned {
                shiftStore.returnCar(in: shift, car: car)
            }
        }
    }
}
