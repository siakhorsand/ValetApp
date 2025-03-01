//
//  ValetTheme.swift
//  Valet
//
//  Created by Sia Khorsand on 2/28/25.
//

import SwiftUI

struct ValetTheme {
    // Main colors
    static let background = Color(hex: "121212")
    static let surface = Color(hex: "1E1E1E")
    static let surfaceVariant = Color(hex: "282828")
    static let primary = Color(hex: "BB86FC")
    static let primaryVariant = Color(hex: "3700B3")
    static let secondary = Color(hex: "03DAC6")
    static let accent = Color(hex: "CF6679")
    
    // Text colors
    static let onBackground = Color.white
    static let onSurface = Color.white
    static let onPrimary = Color.black
    static let onSecondary = Color.black
    static let textSecondary = Color(hex: "B3B3B3")
    
    // Status colors
    static let success = Color(hex: "4CAF50")
    static let warning = Color(hex: "FFAB40")
    static let error = Color(hex: "CF6679")
    
    // Gradients
    static let primaryGradient = LinearGradient(
        gradient: Gradient(colors: [primary, Color(hex: "7F39FB")]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        gradient: Gradient(colors: [secondary, Color(hex: "018786")]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Card styles
    static func card(isActive: Bool = true) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isActive ? surfaceVariant : surfaceVariant.opacity(0.7))
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
    
    // Button styles
    struct PrimaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .frame(maxWidth: .infinity)
                .background(primaryGradient)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
                .scaleEffect(configuration.isPressed ? 0.98 : 1)
                .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
        }
    }
    
    struct SecondaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .frame(maxWidth: .infinity)
                .background(accentGradient)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
                .scaleEffect(configuration.isPressed ? 0.98 : 1)
                .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
        }
    }
    
    struct TextButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .foregroundColor(primary)
                .scaleEffect(configuration.isPressed ? 0.98 : 1)
                .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
        }
    }
}

// Extension for hex color initialization
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
