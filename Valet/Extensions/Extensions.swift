//
//  Extensions.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//

import Foundation
import SwiftUICore

extension Date {
    /// Rounds the date to the nearest 15 minutes (down or up).
    func roundedToNearest15Min() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        guard let minute = components.minute,
              let baseDate = calendar.date(from: components) else {
            return self
        }
        let remainder = minute % 15
        let half = 15 / 2
        let direction = remainder < half ? -remainder : (15 - remainder)
        return calendar.date(byAdding: .minute, value: direction, to: baseDate) ?? self
    }

    /// Format to something like "h a" -> "6 PM"
    func toHourString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        return formatter.string(from: self)
    }
}

extension String {
    /// Takes "John Smith" -> "J. Smith"; or "Alice DeLorean" -> "A. DeLorean"
    func abbreviatedName() -> String {
        let parts = self.split(separator: " ")
        guard let first = parts.first else { return self }
        let firstInitial = first.prefix(1).uppercased() + "."
        if parts.count > 1 {
            var lastName = parts.dropFirst().joined(separator: " ")
            // Just capitalize the first letter of the last name if needed
            lastName = lastName.prefix(1).capitalized + lastName.dropFirst()
            return "\(firstInitial) \(lastName)"
        } else {
            // Single name fallback
            return self
        }
    }
}


extension AnyTransition {
    static var moveAndFade: AnyTransition {
        let insertion = AnyTransition.move(edge: .bottom)
            .combined(with: .opacity)
        let removal = AnyTransition.move(edge: .bottom)
            .combined(with: .opacity)
        return .asymmetric(insertion: insertion, removal: removal)
    }
}
