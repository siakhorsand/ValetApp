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
#if DEBUG
struct ValetTheme_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Colors
                Group {
                    Text("Theme Colors")
                        .font(.headline)
                    
                    HStack {
                        ColorSwatch(color: ValetTheme.background, name: "Background")
                        ColorSwatch(color: ValetTheme.surface, name: "Surface")
                        ColorSwatch(color: ValetTheme.surfaceVariant, name: "SurfaceVariant")
                    }
                    
                    HStack {
                        ColorSwatch(color: ValetTheme.primary, name: "Primary")
                        ColorSwatch(color: ValetTheme.primaryVariant, name: "PrimaryVariant")
                        ColorSwatch(color: ValetTheme.secondary, name: "Secondary")
                    }
                    
                    HStack {
                        ColorSwatch(color: ValetTheme.success, name: "Success")
                        ColorSwatch(color: ValetTheme.warning, name: "Warning")
                        ColorSwatch(color: ValetTheme.error, name: "Error")
                    }
                }
                
                // Gradients
                Group {
                    Text("Theme Gradients")
                        .font(.headline)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ValetTheme.primaryGradient)
                        .frame(height: 50)
                        .overlay(Text("Primary Gradient").foregroundColor(.white))
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ValetTheme.accentGradient)
                        .frame(height: 50)
                        .overlay(Text("Accent Gradient").foregroundColor(.white))
                }
                
                // Buttons
                Group {
                    Text("Theme Buttons")
                        .font(.headline)
                    
                    Button("Primary Button") {}
                        .buttonStyle(ValetTheme.PrimaryButtonStyle())
                    
                    Button("Secondary Button") {}
                        .buttonStyle(ValetTheme.SecondaryButtonStyle())
                    
                    Button("Text Button") {}
                        .buttonStyle(ValetTheme.TextButtonStyle())
                }
                
                // Card
                Group {
                    Text("Theme Card")
                        .font(.headline)
                    
                    ValetTheme.card(isActive: true)
                        .frame(height: 100)
                        .overlay(Text("Active Card").foregroundColor(.white))
                    
                    ValetTheme.card(isActive: false)
                        .frame(height: 100)
                        .overlay(Text("Inactive Card").foregroundColor(.white))
                }
            }
            .padding()
        }
        .background(ValetTheme.background)
        .preferredColorScheme(.dark)
    }
    
    // Helper view for color swatches
    struct ColorSwatch: View {
        let color: Color
        let name: String
        
        var body: some View {
            VStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .frame(width: 100, height: 50)
                
                Text(name)
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
    }
}
#endif
