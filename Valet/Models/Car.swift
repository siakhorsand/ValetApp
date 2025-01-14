//
//  Car.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//

import Foundation

struct Car: Identifiable {
    let id = UUID()
    var licensePlate: String
    var make: String
    var model: String
    var color: String
    var locationParked: String
    var arrivalTime: Date = Date()
    var departureTime: Date?
    var isReturned: Bool = false
    var parkedBy: Employee? // Which employee parked the car
}
