//
//  Shift.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//

import SwiftUI

// ShiftStore.swift
import SwiftUI

class ShiftStore: ObservableObject {
    @Published var shifts: [Shift] = []
    @Published var allEmployees: [Employee] = []

    func startShift(customerName: String, address: String) -> Shift {
        let newShift = Shift(customerName: customerName, address: address)
        shifts.append(newShift)
        return newShift
    }

    func endShift(_ shift: Shift) {
        guard let idx = shifts.firstIndex(where: { $0.id == shift.id }) else { return }
        shifts[idx].endTime = Date()
    }

    func addCar(to shift: Shift,
                licensePlate: String,
                make: String,
                model: String,
                color: String,
                location: String,
                parkedBy: Employee?) {
        guard let idx = shifts.firstIndex(where: { $0.id == shift.id }) else { return }
        let newCar = Car(
            licensePlate: licensePlate,
            make: make,
            model: model,
            color: color,
            locationParked: location,
            parkedBy: parkedBy
        )
        shifts[idx].cars.append(newCar)
    }

    func returnCar(in shift: Shift, car: Car) {
        guard let shiftIdx = shifts.firstIndex(where: { $0.id == shift.id }) else { return }
        guard let carIdx = shifts[shiftIdx].cars.firstIndex(where: { $0.id == car.id }) else { return }
        shifts[shiftIdx].cars[carIdx].isReturned = true
        shifts[shiftIdx].cars[carIdx].departureTime = Date()
    }

    // Creates a random-colored employee and adds them
    func addEmployee(name: String) {
        let randomColor = Color(
            hue: Double.random(in: 0...1),
            saturation: 0.7,
            brightness: 0.9
        )
        let employee = Employee(name: name, color: randomColor)
        allEmployees.append(employee)
    }
}
