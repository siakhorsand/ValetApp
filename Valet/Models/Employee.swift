//
//  Employee.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//

import SwiftUI

struct Employee: Identifiable, Hashable {
    let id: UUID = UUID()
    let name: String
    let color: Color
}

