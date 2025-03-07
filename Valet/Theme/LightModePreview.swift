//
//  LightModePreview.swift
//  Valet
//
//  Created by Sia Khorsand on 3/7/25.
//



import SwiftUI

struct ModernLightModePreview: View {
    @Environment(\.colorScheme) private var colorScheme
    let colors = ValetTheme.dynamicColors(for: .light) // Force light mode for preview
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern gradient background
                ValetTheme.dynamicBackgroundGradient(colorScheme: .light)
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 5) {
                            Text("Modern Light Theme")
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(colors.primary)
                            
                            Text("Sleek & Sophisticated")
                                .font(.subheadline)
                                .foregroundColor(colors.textSecondary)
                        }
                        .padding(.top, 20)
                        
                        // Demo cards showing components against the background
                        VStack(spacing: 18) {
                            // Modern card
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(colors.surface)
                                    .shadow(
                                        color: Color.black.opacity(0.08),
                                        radius: 15,
                                        x: 0,
                                        y: 5
                                    )
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Circle()
                                            .fill(colors.primary)
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Image(systemName: "car.fill")
                                                    .foregroundColor(.white)
                                            )
                                        
                                        Spacer()
                                        
                                        Text("09:30 AM")
                                            .font(.caption)
                                            .foregroundColor(colors.textSecondary)
                                    }
                                    
                                    Text("BMW X5")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(colors.onSurface)
                                    
                                    Text("License: ABC123")
                                        .font(.subheadline)
                                        .foregroundColor(colors.primary)
                                    
                                    Text("Location: Front Row #12")
                                        .font(.body)
                                        .foregroundColor(colors.textSecondary)
                                    
                                    Divider()
                                        .background(colors.primary.opacity(0.2))
                                    
                                    HStack(spacing: 0) {
                                        Text("Parked by ")
                                            .font(.subheadline)
                                            .foregroundColor(colors.textSecondary)
                                        
                                        Text("John")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(colors.primary)
                                    }
                                }
                                .padding(20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(height: 200)
                            
                            // Second card with accent gradient
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(colors.surfaceVariant)
                                    .shadow(
                                        color: Color.black.opacity(0.06),
                                        radius: 10,
                                        x: 0,
                                        y: 3
                                    )
                                
                                VStack(alignment: .center, spacing: 15) {
                                    Text("New Parking Session")
                                        .font(.headline)
                                        .foregroundColor(colors.onSurface)
                                    
                                    HStack(spacing: 15) {
                                        Button(action: {}) {
                                            Label("Create", systemImage: "plus.circle.fill")
                                                .padding(.vertical, 10)
                                                .padding(.horizontal, 20)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(ValetTheme.DynamicPrimaryButtonStyle())
                                        
                                        Button(action: {}) {
                                            Label("Join", systemImage: "person.badge.key.fill")
                                                .padding(.vertical, 10)
                                                .padding(.horizontal, 20)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(ValetTheme.DynamicSecondaryButtonStyle())
                                    }
                                }
                                .padding(20)
                            }
                            .frame(height: 130)
                        }
                        .padding(.horizontal)
                        
                        // Color palette showcase
                        VStack(alignment: .leading, spacing: 15) {
                            Text("MODERN COLOR PALETTE")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(colors.primary)
                                .padding(.leading)
                            
                            VStack(spacing: 10) {
                                HStack(spacing: 10) {
                                    ColorSwatch(color: colors.background, name: "Background")
                                    ColorSwatch(color: colors.surface, name: "Surface")
                                    ColorSwatch(color: colors.surfaceVariant, name: "Surface Variant")
                                }
                                
                                HStack(spacing: 10) {
                                    ColorSwatch(color: colors.primary, name: "Primary")
                                    ColorSwatch(color: colors.secondary, name: "Secondary")
                                    ColorSwatch(color: colors.accent, name: "Accent")
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(colors.surface)
                                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                            )
                            .padding(.horizontal)
                        }
                        
                        // Material design inspired form
                        VStack(alignment: .leading, spacing: 15) {
                            Text("MODERN FORM CONTROLS")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(colors.primary)
                                .padding(.leading)
                            
                            VStack(spacing: 18) {
                                ModernFormField(
                                    icon: "person.fill",
                                    label: "DRIVER",
                                    text: .constant("John Smith"),
                                    colors: colors
                                )
                                
                                ModernFormField(
                                    icon: "car.fill",
                                    label: "VEHICLE",
                                    text: .constant("Tesla Model S"),
                                    colors: colors
                                )
                                
                                ModernFormField(
                                    icon: "location.fill",
                                    label: "LOCATION",
                                    text: .constant("Front Row #7"),
                                    colors: colors
                                )
                                
                                Button(action: {}) {
                                    Text("Submit")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                }
                                .buttonStyle(ValetTheme.DynamicPrimaryButtonStyle())
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(colors.surface)
                                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                            )
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .navigationTitle("Modern Light Theme")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.light)
    }
    
    // Color swatch for the palette showcase
    struct ColorSwatch: View {
        let color: Color
        let name: String
        
        var body: some View {
            VStack(spacing: 5) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .frame(height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black.opacity(0.05), lineWidth: 1)
                    )
                
                Text(name)
                    .font(.caption)
                    .foregroundColor(ValetTheme.dynamicColors(for: .light).textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // Modern styled form field
    struct ModernFormField: View {
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
                
                HStack {
                    TextField("", text: $text)
                        .foregroundColor(colors.onSurface)
                    
                    if !text.isEmpty {
                        Button(action: {}) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(colors.textSecondary.opacity(0.5))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colors.surfaceVariant)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(colors.primary.opacity(0.4), lineWidth: 1.5)
                )
            }
        }
    }
}

// MARK: - Preview
struct ModernLightModePreview_Previews: PreviewProvider {
    static var previews: some View {
        ModernLightModePreview()
            .preferredColorScheme(.light)
    }
}
