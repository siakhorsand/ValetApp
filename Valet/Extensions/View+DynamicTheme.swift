//
//  View+DynamicTheme.swift
//  Valet


import SwiftUI

extension View {
    /// Apply dynamic theme colors to a view based on the current color scheme
    /// This makes it easy to convert existing views to support both light and dark modes
    func withDynamicTheme() -> some View {
        self.modifier(DynamicThemeModifier())
    }
    
    /// Get the theme colors for the current environment's color scheme
    func themeColors() -> DynamicThemeColors {
        @Environment(\.colorScheme) var colorScheme
        return ValetTheme.dynamicColors(for: colorScheme)
    }
    
    /// Apply a background color based on the current color scheme
    func dynamicBackground() -> some View {
        self.modifier(DynamicBackgroundModifier())
    }
    
    /// Apply a stylish gradient background based on the current color scheme
    func dynamicGradientBackground() -> some View {
        self.background(
            ZStack {
                @Environment(\.colorScheme) var colorScheme
                ValetTheme.dynamicBackgroundGradient(colorScheme: colorScheme)
            }
        )
    }
    
    /// Apply a dynamic surface color based on the current color scheme
    func dynamicSurface(cornerRadius: CGFloat = 12) -> some View {
        self.modifier(DynamicSurfaceModifier(cornerRadius: cornerRadius))
    }
    
    /// Apply a dynamic surface variant color based on the current color scheme
    func dynamicSurfaceVariant(cornerRadius: CGFloat = 12) -> some View {
        self.modifier(DynamicSurfaceVariantModifier(cornerRadius: cornerRadius))
    }
    
    /// Apply dynamic text coloring based on the current color scheme
    func dynamicText(type: DynamicTextType = .primary) -> some View {
        self.modifier(DynamicTextModifier(type: type))
    }
}

// MARK: - Dynamic Theme Modifiers

/// Modifier to provide dynamic theme colors to a view
struct DynamicThemeModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content.environment(\.dynamicThemeColors, ValetTheme.dynamicColors(for: colorScheme))
    }
}

/// Modifier to apply dynamic background color
struct DynamicBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content.background(ValetTheme.dynamicColors(for: colorScheme).background)
    }
}

/// Modifier to apply dynamic surface color with optional corner radius
struct DynamicSurfaceModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content.background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(ValetTheme.dynamicColors(for: colorScheme).surface)
        )
    }
}

/// Modifier to apply dynamic surface variant color with optional corner radius
struct DynamicSurfaceVariantModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content.background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(ValetTheme.dynamicColors(for: colorScheme).surfaceVariant)
        )
    }
}

/// Text color types for dynamic coloring
enum DynamicTextType {
    case primary
    case secondary
    case onSurface
    case onBackground
    case accent
}

/// Modifier to apply dynamic text coloring based on type
struct DynamicTextModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let type: DynamicTextType
    
    func body(content: Content) -> some View {
        let colors = ValetTheme.dynamicColors(for: colorScheme)
        
        let textColor: Color = {
            switch type {
            case .primary:
                return colors.primary
            case .secondary:
                return colors.textSecondary
            case .onSurface:
                return colors.onSurface
            case .onBackground:
                return colors.onBackground
            case .accent:
                return colors.accent
            }
        }()
        
        return content.foregroundColor(textColor)
    }
}

// MARK: - Environment Values Extension

// Create an environment key for dynamic theme colors
struct DynamicThemeColorsKey: EnvironmentKey {
    static let defaultValue = ValetTheme.dynamicColors(for: .dark)
}

// Extend EnvironmentValues to include dynamic theme colors
extension EnvironmentValues {
    var dynamicThemeColors: DynamicThemeColors {
        get { self[DynamicThemeColorsKey.self] }
        set { self[DynamicThemeColorsKey.self] = newValue }
    }
}
