//
//  ThemePreview.swift
//  Valet
//
//  Created by Sia Khorsand on 3/7/25.
//


import SwiftUI

struct ThemePreview: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        let colors = ValetTheme.dynamicColors(for: colorScheme)
        
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Theme title
                    Text("Valet Theme")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(colors.primary)
                    
                    Text(colorScheme == .dark ? "Dark Mode" : "Light Mode")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(colors.primary.opacity(0.2))
                        )
                        .foregroundColor(colors.primary)
                    
                    // Colors section
                    SectionTitle(title: "Colors", colors: colors)
                    
                    VStack(spacing: 16) {
                        // Background and Surface colors
                        HStack(spacing: 12) {
                            ColorSwatch(color: colors.background, name: "Background", isDark: colorScheme == .dark)
                            ColorSwatch(color: colors.surface, name: "Surface", isDark: colorScheme == .dark)
                            ColorSwatch(color: colors.surfaceVariant, name: "Surface Variant", isDark: colorScheme == .dark)
                        }
                        
                        // Primary and accent colors
                        HStack(spacing: 12) {
                            ColorSwatch(color: colors.primary, name: "Primary", isDark: colorScheme == .dark)
                            ColorSwatch(color: colors.primaryVariant, name: "Primary Variant", isDark: colorScheme == .dark)
                            ColorSwatch(color: colors.secondary, name: "Secondary", isDark: colorScheme == .dark)
                        }
                        
                        // Status colors
                        HStack(spacing: 12) {
                            ColorSwatch(color: colors.success, name: "Success", isDark: colorScheme == .dark)
                            ColorSwatch(color: colors.warning, name: "Warning", isDark: colorScheme == .dark)
                            ColorSwatch(color: colors.error, name: "Error", isDark: colorScheme == .dark)
                        }
                    }
                    
                    // Gradients section
                    SectionTitle(title: "Gradients", colors: colors)
                    
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Primary Gradient")
                                .font(.caption)
                                .foregroundColor(colors.textSecondary)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(ValetTheme.dynamicPrimaryGradient(colorScheme: colorScheme))
                                .frame(height: 60)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Accent Gradient")
                                .font(.caption)
                                .foregroundColor(colors.textSecondary)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(ValetTheme.dynamicAccentGradient(colorScheme: colorScheme))
                                .frame(height: 60)
                        }
                    }
                    
                    // Components section
                    SectionTitle(title: "Components", colors: colors)
                    
                    // Cards
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cards")
                            .font(.subheadline)
                            .foregroundColor(colors.textSecondary)
                        
                        HStack(spacing: 12) {
                            // Active card
                            ValetTheme.dynamicCard(colorScheme: colorScheme, isActive: true)
                                .frame(height: 80)
                                .overlay(
                                    Text("Active Card")
                                        .foregroundColor(colors.onSurface)
                                )
                            
                            // Inactive card
                            ValetTheme.dynamicCard(colorScheme: colorScheme, isActive: false)
                                .frame(height: 80)
                                .overlay(
                                    Text("Inactive Card")
                                        .foregroundColor(colors.onSurface)
                                )
                        }
                    }
                    
                    // Button styles
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Buttons")
                            .font(.subheadline)
                            .foregroundColor(colors.textSecondary)
                        
                        Button(action: {}) {
                            Text("Primary Button")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(ValetTheme.DynamicPrimaryButtonStyle())
                        
                        Button(action: {}) {
                            Text("Secondary Button")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(ValetTheme.DynamicSecondaryButtonStyle())
                        
                        Button(action: {}) {
                            Text("Text Button")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(ValetTheme.DynamicTextButtonStyle())
                    }
                    
                    // Text styles
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Typography")
                            .font(.subheadline)
                            .foregroundColor(colors.textSecondary)
                        
                        Text("Heading")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(colors.onBackground)
                        
                        Text("Subheading")
                            .font(.headline)
                            .foregroundColor(colors.onBackground)
                        
                        Text("Body text with a slightly longer paragraph to demonstrate how body text appears in the theme. The color and weight are optimized for readability.")
                            .font(.body)
                            .foregroundColor(colors.onBackground)
                        
                        Text("Secondary text")
                            .font(.subheadline)
                            .foregroundColor(colors.textSecondary)
                        
                        Text("Caption text")
                            .font(.caption)
                            .foregroundColor(colors.textSecondary)
                    }
                    
                    // Dynamic form field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Form Elements")
                            .font(.subheadline)
                            .foregroundColor(colors.textSecondary)
                        
                        DynamicFormField(icon: "envelope.fill", label: "EMAIL", text: .constant("user@example.com"), colors: colors)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .background(colors.background)
            .navigationTitle("Theme Preview")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("Change in Settings")
                        .font(.caption)
                        .foregroundColor(colors.textSecondary)
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    // Section title view
    struct SectionTitle: View {
        let title: String
        let colors: DynamicThemeColors
        
        var body: some View {
            HStack {
                Text(title.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(colors.primary)
                
                Rectangle()
                    .fill(colors.primary.opacity(0.3))
                    .frame(height: 1)
            }
            .padding(.top, 8)
        }
    }
    
    // Color swatch view
    struct ColorSwatch: View {
        let color: Color
        let name: String
        let isDark: Bool
        
        var body: some View {
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .frame(height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black.opacity(0.1), lineWidth: isDark ? 0 : 1)
                    )
                
                Text(name)
                    .font(.caption)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // Dynamic form field
    struct DynamicFormField: View {
        var icon: String
        var label: String
        @Binding var text: String
        var colors: DynamicThemeColors
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(colors.primary)
                    Text(label)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(colors.primary)
                }
                
                TextField("", text: $text)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(colors.surfaceVariant)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(colors.primary.opacity(0.6), lineWidth: 2)
                    )
                    .foregroundColor(colors.onSurface)
            }
        }
    }
}

// MARK: - Previews
struct ThemePreview_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ThemePreview()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            ThemePreview()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
