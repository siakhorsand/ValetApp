//
//  Shift.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//
import Foundation


struct Shift: Identifiable {
    let id = UUID()
    var customerName: String
    var address: String
    var startTime: Date = Date()
    var endTime: Date?
    var cars: [Car] = []
    var employees: [Employee] = []

    var isEnded: Bool { endTime != nil }
}
