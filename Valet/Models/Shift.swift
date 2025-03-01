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
    var shiftCode: String
    
    init(customerName: String, address: String) {
        self.customerName = customerName
        self.address = address
        self.shiftCode = Shift.generateRandomCode()
    }
    
    var isEnded: Bool { endTime != nil }
    
    // Generates a random 6-character alphanumeric code
    static func generateRandomCode() -> String {
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789" // Omitting easily confused characters like 0/O, 1/I
        var code = ""
        for _ in 0..<6 {
            if let randomChar = characters.randomElement() {
                code.append(randomChar)
            }
        }
        return code
    }
}
