//
//  DynamicThemeUsagePreview.swift
//  Valet
//
//  Created by Sia Khorsand on 3/7/25.
//


import SwiftUI

struct DynamicThemeUsagePreview: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var text = "Sample input"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    Text("Dynamic Theme Usage")
                        .font(.title2)
                        .fontWeight(.bold)
                        .dynamicText(type: .primary)
                    
                    Text("Current mode: \(colorScheme == .dark ? "Dark" : "Light")")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .dynamicSurfaceVariant(cornerRadius: 20)
                        .dynamicText(type: .secondary)
                    
                    // Examples section
                    Group {
                        Text("Before & After Examples")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .dynamicText(type: .primary)
                        
                        // Original VS Dynamic Card
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Cards")
                                .font(.subheadline)
                                .dynamicText(type: .secondary)
                            
                            HStack(spacing: 12) {
                                // Original card
                                VStack {
                                    Text("Original")
                                        .font(.caption)
                                        .dynamicText(type: .secondary)
                                    
                                    ValetTheme.card()
                                        .frame(height: 80)
                                        .overlay(
                                            Text("Fixed Styling")
                                                .foregroundColor(.white)
                                        )
                                }
                                
                                // Dynamic card
                                VStack {
                                    Text("Dynamic")
                                        .font(.caption)
                                        .dynamicText(type: .secondary)
                                    
                                    ValetTheme.dynamicCard(colorScheme: colorScheme)
                                        .frame(height: 80)
                                        .overlay(
                                            Text("Adapts to Theme")
                                                .dynamicText(type: .onSurface)
                                        )
                                }
                            }
                        }
                        
                        // Original VS Dynamic Buttons
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Buttons")
                                .font(.subheadline)
                                .dynamicText(type: .secondary)
                            
                            HStack(spacing: 12) {
                                // Original button
                                VStack {
                                    Text("Original")
                                        .font(.caption)
                                        .dynamicText(type: .secondary)
                                    
                                    Button("Button") {}
                                        .buttonStyle(ValetTheme.PrimaryButtonStyle())
                                        .frame(maxWidth: .infinity)
                                }
                                
                                // Dynamic button
                                VStack {
                                    Text("Dynamic")
                                        .font(.caption)
                                        .dynamicText(type: .secondary)
                                    
                                    Button("Button") {}
                                        .buttonStyle(ValetTheme.DynamicPrimaryButtonStyle())
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }
                    
                    // Usage Examples section
                    Group {
                        Text("Usage Examples")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .dynamicText(type: .primary)
                        
                        // Example 1: View modifiers
                        VStack(alignment: .leading, spacing: 8) {
                            Text("View Modifiers")
                                .font(.subheadline)
                                .dynamicText(type: .secondary)
                            
                            Text("Apply these modifiers to any view:")
                                .font(.caption)
                                .dynamicText(type: .secondary)
                            
                            Group {
                                Text(".dynamicBackground()")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .dynamicBackground()
                                    .dynamicText(type: .onBackground)
                                
                                Text(".dynamicSurface()")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .dynamicSurface()
                                    .dynamicText(type: .onSurface)
                                
                                Text(".dynamicSurfaceVariant()")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .dynamicSurfaceVariant()
                                    .dynamicText(type: .onSurface)
                                
                                Text(".dynamicText(type: .primary)")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .dynamicSurfaceVariant()
                                    .dynamicText(type: .primary)
                                
                                Text(".dynamicText(type: .secondary)")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .dynamicSurfaceVariant()
                                    .dynamicText(type: .secondary)
                            }
                        }
                        
                        // Example 2: Environment access
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Environment Usage")
                                .font(.subheadline)
                                .dynamicText(type: .secondary)
                            
                            VStack(spacing: 12) {
                                EnvironmentThemeExample()
                                
                                Text("Form field example using environment:")
                                    .font(.caption)
                                    .dynamicText(type: .secondary)
                                
                                // Use the environment to get theme colors
                                DynamicFormField(text: $text)
                            }
                            .padding()
                            .dynamicSurfaceVariant()
                        }
                    }
                    
                    // Converting hints
                    Group {
                        Text("How to Convert Views")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .dynamicText(type: .primary)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("1. Replace static colors with dynamic ones")
                                .font(.subheadline)
                                .dynamicText(type: .onBackground)
                            
                            Text("2. Use .dynamicText(), .dynamicBackground() modifiers")
                                .font(.subheadline)
                                .dynamicText(type: .onBackground)
                            
                            Text("3. Replace gradients with dynamic variants")
                                .font(.subheadline)
                                .dynamicText(type: .onBackground)
                            
                            Text("4. Update buttons to use dynamic button styles")
                                .font(.subheadline)
                                .dynamicText(type: .onBackground)
                            
                            Text("5. Use Environment(\\.\\.colorScheme) when needed")
                                .font(.subheadline)
                                .dynamicText(type: .onBackground)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .dynamicSurface()
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .dynamicBackground()
            .navigationTitle("Dynamic Theme")
        }
        .withDynamicTheme()
    }
}

// Example of using environment to access theme colors
struct EnvironmentThemeExample: View {
    @Environment(\.dynamicThemeColors) private var colors
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Example using @Environment(\\.\\.dynamicThemeColors)")
                .font(.caption)
                .foregroundColor(colors.textSecondary)
            
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(colors.primary)
                    .frame(width: 50, height: 50)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(colors.secondary)
                    .frame(width: 50, height: 50)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(colors.accent)
                    .frame(width: 50, height: 50)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colors.surface)
        )
    }
}

// Dynamic form field using environment
struct DynamicFormField: View {
    @Binding var text: String
    @Environment(\.dynamicThemeColors) private var colors
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("INPUT FIELD")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(colors.primary)
            
            TextField("Enter text", text: $text)
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

// MARK: - Previews
struct DynamicThemeUsagePreview_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DynamicThemeUsagePreview()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            DynamicThemeUsagePreview()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
