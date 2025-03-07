//
//  ValetTheme+LightMode.swift
//  Valet
//
//  Created by Claude on 3/7/25.
//

import SwiftUI

// Extension to ValetTheme to support light mode with a cool aesthetic
extension ValetTheme {
    // MARK: - Light Mode Colors
    
    // Light mode variant of the theme - respects system settings
    static func dynamicColors(for colorScheme: ColorScheme) -> DynamicThemeColors {
        colorScheme == .dark ? darkColors : lightColors
    }
    
    // Dark mode colors (original theme)
    private static let darkColors = DynamicThemeColors(
        background: Color(hex: "121212"),
        surface: Color(hex: "1E1E1E"),
        surfaceVariant: Color(hex: "282828"),
        primary: Color(hex: "BB86FC"),
        primaryVariant: Color(hex: "3700B3"),
        secondary: Color(hex: "03DAC6"),
        accent: Color(hex: "CF6679"),
        onBackground: Color.white,
        onSurface: Color.white,
        onPrimary: Color.black,
        onSecondary: Color.black,
        textSecondary: Color(hex: "B3B3B3"),
        success: Color(hex: "4CAF50"),
        warning: Color(hex: "FFAB40"),
        error: Color(hex: "CF6679")
    )
    
    // Light mode colors (modern and sleek with interesting backgrounds)
    private static let lightColors = DynamicThemeColors(
        background: Color(hex: "EEF2FF"),
        surface: Color(hex: "F8F9FF"),
        surfaceVariant: Color(hex: "E3E8F8"),
        primary: Color(hex: "6A3DE8"),
        primaryVariant: Color(hex: "4C2DBB"),
        secondary: Color(hex: "00B8A9"),
        accent: Color(hex: "F45866"),
        onBackground: Color(hex: "222230"),
        onSurface: Color(hex: "222230"),
        onPrimary: Color.white,
        onSecondary: Color.white,
        textSecondary: Color(hex: "72737A"),
        success: Color(hex: "2E7D32"),
        warning: Color(hex: "F57C00"),
        error: Color(hex: "D32F2F")
    )
    
    // MARK: - Dynamic Theme Elements
    
    // Dynamic card style that adjusts based on color scheme
    static func dynamicCard(colorScheme: ColorScheme, isActive: Bool = true) -> some View {
        let colors = dynamicColors(for: colorScheme)
        return RoundedRectangle(cornerRadius: 12)
            .fill(isActive ? colors.surfaceVariant : colors.surfaceVariant.opacity(0.7))
            .shadow(
                color: colorScheme == .dark
                    ? Color.black.opacity(0.2)
                    : Color.black.opacity(0.1),
                radius: colorScheme == .dark ? 8 : 4,
                x: 0,
                y: colorScheme == .dark ? 4 : 2
            )
    }
  
  
    static func dynamicPrimaryGradient(colorScheme: ColorScheme) -> LinearGradient {
        let colors = dynamicColors(for: colorScheme)
        return LinearGradient(
            gradient: Gradient(colors: [colors.primary, colors.primaryVariant]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Dynamic accent gradient for buttons
    static func dynamicAccentGradient(colorScheme: ColorScheme) -> LinearGradient {
        let colors = dynamicColors(for: colorScheme)
        return LinearGradient(
            gradient: Gradient(colors: [colors.secondary, colors.secondary.opacity(0.8)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }



    static func dynamicBackgroundGradient(colorScheme: ColorScheme) -> some View {
        let colors = dynamicColors(for: colorScheme)
        
        if colorScheme == .dark {
   
            return AnyView(
                RadialGradient(
                    gradient: Gradient(colors: [
                        colors.surfaceVariant.opacity(0.3),
                        colors.background
                    ]),
                    center: .topLeading,
                    startRadius: 100,
                    endRadius: 600
                )
                .ignoresSafeArea()
            )
        } else {
            // Light mode gradient - subtly layered effect that looks modern and sleek
            return AnyView(
                ZStack {
                    // Base color
                    colors.background.ignoresSafeArea()
                    
                    // Top-right accent
                    RadialGradient(
                        gradient: Gradient(colors: [
                            colors.primary.opacity(0.08),
                            colors.primary.opacity(0.0)
                        ]),
                        center: .topTrailing,
                        startRadius: 0,
                        endRadius: 400
                    )
                    .ignoresSafeArea()
                    
                    // Bottom-left accent
                    RadialGradient(
                        gradient: Gradient(colors: [
                            colors.secondary.opacity(0.07),
                            colors.secondary.opacity(0.0)
                        ]),
                        center: .bottomLeading,
                        startRadius: 5,
                        endRadius: 500
                    )
                    .ignoresSafeArea()
                    
                    // Subtle dot pattern overlay for texture (in light mode only)
                    DotPatternView(
                        dotSize: 1.2,
                        spacing: 20,
                        color: .black
                    )
                    .opacity(0.03)
                    .ignoresSafeArea()
                    .blendMode(.overlay)
                }
            )
        }
    }
    
    // MARK: - Dynamic Button Styles
    
    // Dynamic primary button style
    struct DynamicPrimaryButtonStyle: ButtonStyle {
        @Environment(\.colorScheme) private var colorScheme
        
        func makeBody(configuration: Configuration) -> some View {
            let colors = ValetTheme.dynamicColors(for: colorScheme)
            
            configuration.label
                .padding()
                .frame(maxWidth: .infinity)
                .background(ValetTheme.dynamicPrimaryGradient(colorScheme: colorScheme))
                .foregroundColor(colors.onPrimary)
                .cornerRadius(12)
                .shadow(
                    color: colors.primary.opacity(colorScheme == .dark ? 0.3 : 0.2),
                    radius: colorScheme == .dark ? 5 : 3,
                    x: 0,
                    y: colorScheme == .dark ? 3 : 2
                )
                .scaleEffect(configuration.isPressed ? 0.98 : 1)
                .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
        }
    }
    
    // Dynamic secondary button style
    struct DynamicSecondaryButtonStyle: ButtonStyle {
        @Environment(\.colorScheme) private var colorScheme
        
        func makeBody(configuration: Configuration) -> some View {
            let colors = ValetTheme.dynamicColors(for: colorScheme)
            
            configuration.label
                .padding()
                .frame(maxWidth: .infinity)
                .background(ValetTheme.dynamicAccentGradient(colorScheme: colorScheme))
                .foregroundColor(colors.onSecondary)
                .cornerRadius(12)
                .shadow(
                    color: colors.secondary.opacity(colorScheme == .dark ? 0.3 : 0.2),
                    radius: colorScheme == .dark ? 5 : 3,
                    x: 0,
                    y: colorScheme == .dark ? 3 : 2
                )
                .scaleEffect(configuration.isPressed ? 0.98 : 1)
                .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
        }
    }
    
    // Dynamic text button style
    struct DynamicTextButtonStyle: ButtonStyle {
        @Environment(\.colorScheme) private var colorScheme
        
        func makeBody(configuration: Configuration) -> some View {
            let colors = ValetTheme.dynamicColors(for: colorScheme)
            
            configuration.label
                .padding()
                .foregroundColor(colors.primary)
                .scaleEffect(configuration.isPressed ? 0.98 : 1)
                .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
        }
    }
}

// Structure to hold theme colors for either light or dark mode
struct DynamicThemeColors {
    let background: Color
    let surface: Color
    let surfaceVariant: Color
    let primary: Color
    let primaryVariant: Color
    let secondary: Color
    let accent: Color
    let onBackground: Color
    let onSurface: Color
    let onPrimary: Color
    let onSecondary: Color
    let textSecondary: Color
    let success: Color
    let warning: Color
    let error: Color
}

// Usage example wrapper to automatically use dynamic colors
struct ThemedView<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    let content: (DynamicThemeColors) -> Content
    
    init(@ViewBuilder content: @escaping (DynamicThemeColors) -> Content) {
        self.content = content
    }
    
    var body: some View {
        content(ValetTheme.dynamicColors(for: colorScheme))
    }
}
