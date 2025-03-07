//
//  CustomComponents.swift
//  Valet
//
//  Created by Sia Khorsand on 3/7/25.
//


import SwiftUI

// MARK: - Floating Particle
struct FloatingParticle: View {
    let delay: Double
    let size: CGFloat
    
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .fill(ValetTheme.primary.opacity(0.3))
            .frame(width: size, height: size)
            .blur(radius: 1)
            .offset(
                x: isAnimating ? CGFloat.random(in: -100...100) : CGFloat.random(in: -100...100),
                y: isAnimating ? CGFloat.random(in: -300...300) : CGFloat.random(in: -300...300)
            )
            .opacity(isAnimating ? Double.random(in: 0.2...0.6) : 0)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: Double.random(in: 15...25))
                        .repeatForever(autoreverses: true)
                        .delay(delay * 2)
                ) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Enhanced Main Button
struct EnhancedMainButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: LinearGradient
    let delay: Double
    let action: () -> Void
    @State private var isPressed = false
    @State private var appear = false
    
    var body: some View {
        Button(action: {
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
            action()
        }) {
            HStack(spacing: 15) {
                // Icon with simplified design
                ZStack {
                    Circle()
                        .fill(ValetTheme.surfaceVariant)
                        .frame(width: 45, height: 45)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(ValetTheme.primary)
                }
                .scaleEffect(isPressed ? 0.95 : 1)
                
                // Text content
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(ValetTheme.onSurface)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(ValetTheme.textSecondary)
                }
                
                Spacer()
                
                // Chevron with primary color
                Image(systemName: "chevron.right")
                    .foregroundColor(ValetTheme.primary)
                    .font(.subheadline)
                    .offset(x: isPressed ? -5 : 0)
                    .animation(.easeOut(duration: 0.2), value: isPressed)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(ValetTheme.surfaceVariant)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(ValetTheme.primary.opacity(0.6), lineWidth: 2)
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isPressed)
            .opacity(appear ? 1 : 0)
            .blur(radius: appear ? 0 : 10)
            .onAppear {
                withAnimation(.easeOut(duration: 0.7).delay(delay)) {
                    appear = true
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged({ _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                })
                .onEnded({ _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                })
        )
    }
}

// MARK: - Enhanced Main Button View
struct EnhancedMainButtonView: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let delay: Double
    @State private var isPressed = false
    @State private var appear = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 45, height: 45)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }
            .scaleEffect(isPressed ? 0.95 : 1)
            
            // Text content
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(ValetTheme.onSurface)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(ValetTheme.textSecondary)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .foregroundColor(ValetTheme.textSecondary)
                .font(.subheadline)
                .offset(x: isPressed ? -5 : 0)
                .animation(.easeOut(duration: 0.2), value: isPressed)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            ZStack {
                // Button background
                RoundedRectangle(cornerRadius: 16)
                    .fill(ValetTheme.surfaceVariant)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                
                // Top highlight
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.1),
                                .clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .mask(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.black, .clear]),
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                    )
            }
        )
        .scaleEffect(isPressed ? 0.98 : 1)
        .offset(y: isPressed ? 1 : -1)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isPressed)
        .opacity(appear ? 1 : 0)
        .blur(radius: appear ? 0 : 10)
        .onAppear {
            withAnimation(.easeOut(duration: 0.7).delay(delay)) {
                appear = true
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged({ _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                })
                .onEnded({ _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                })
        )
    }
}

// MARK: - Pulsing Animation
struct PulsingAnimation: ViewModifier {
    @State private var pulsate = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(pulsate ? 1.2 : 0.8)
            .opacity(pulsate ? 1 : 0.6)
            .animation(
                Animation.easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true)
            )
            .onAppear {
                pulsate = true
            }
    }
}

// MARK: - Stylish Form Field
struct StylishFormField: View {
    var icon: String
    var label: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(ValetTheme.primary)
                Text(label)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(ValetTheme.primary)
            }
            
            TextField("", text: $text)
                .placeholder(when: text.isEmpty) {
                    Text("Enter \(label.lowercased())")
                        .foregroundColor(ValetTheme.textSecondary.opacity(0.7))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ValetTheme.surfaceVariant)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ValetTheme.primary.opacity(0.6), lineWidth: 2)
                )
                .foregroundColor(ValetTheme.onSurface)
        }
    }
}

// MARK: - QR Code View
struct QRCodeView: View {
    let code: String
    
    var body: some View {
        Image(uiImage: generateQRCode(from: code))
            .resizable()
            .interpolation(.none)
            .scaledToFit()
            .background(Color.white)
            .cornerRadius(8)
    }
    
    // Generate QR code from string
    private func generateQRCode(from string: String) -> UIImage {
        let data = string.data(using: .ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                let context = CIContext()
                if let cgImage = context.createCGImage(output, from: output.extent) {
                    return UIImage(cgImage: cgImage)
                }
            }
        }
        
        // Fallback
        return UIImage(systemName: "qrcode") ?? UIImage()
    }
}

// MARK: - Lottie View
struct LottieView: View {
    let name: String
    
    var body: some View {
        ZStack {
            Image(systemName: "car.circle")
                .font(.system(size: 60))
                .foregroundColor(ValetTheme.primary.opacity(0.3))
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(ValetTheme.primary.opacity(0.7))
                        .offset(x: 15, y: 15)
                )
        }
    }
}


#if DEBUG
struct CustomComponents_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 30) {
                Group {
                    Text("Floating Particles")
                        .font(.headline)
                    
                    ZStack {
                        Color.black.opacity(0.8)
                        
                        ForEach(0..<5, id: \.self) { index in
                            FloatingParticle(delay: Double(index) * 0.2, size: 10)
                        }
                    }
                    .frame(height: 150)
                    .cornerRadius(12)
                }
                
                Group {
                    Text("Enhanced Main Button")
                        .font(.headline)
                    
                    EnhancedMainButton(
                        title: "Preview Button",
                        subtitle: "This is a subtitle",
                        icon: "star.fill",
                        gradient: ValetTheme.primaryGradient,
                        delay: 0
                    ) {
                        print("Button tapped")
                    }
                    
                    EnhancedMainButtonView(
                        title: "Button View",
                        subtitle: "Another subtitle",
                        icon: "heart.fill",
                        color: ValetTheme.success,
                        delay: 0
                    )
                }
                
                Group {
                    Text("Pulsing Animation")
                        .font(.headline)
                    
                    Circle()
                        .fill(ValetTheme.primary)
                        .frame(width: 50, height: 50)
                        .modifier(PulsingAnimation())
                }
                
                Group {
                    Text("Stylish Form Field")
                        .font(.headline)
                    
                    StylishFormField(
                        icon: "envelope.fill",
                        label: "EMAIL",
                        text: .constant("test@example.com")
                    )
                    .padding(.horizontal)
                }
                
                Group {
                    Text("QR Code View")
                        .font(.headline)
                    
                    QRCodeView(code: "TEST123")
                        .frame(width: 150, height: 150)
                }
                
                Group {
                    Text("Lottie View")
                        .font(.headline)
                    
                    LottieView(name: "test-animation")
                        .frame(width: 100, height: 100)
                }
            }
            .padding()
        }
        .background(ValetTheme.background)
        .preferredColorScheme(.dark)
    }
}
#endif
