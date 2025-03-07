//
//  DotPatternGenerator.swift
//  Valet
//
//  Created by Sia Khorsand on 3/7/25.
//

import SwiftUI

/// A view that generates a dot pattern for use as a background texture
/// Since we may not have the ability to add image assets directly,
/// this view allows us to generate the pattern programmatically
struct DotPatternView: View {
    let dotSize: CGFloat
    let spacing: CGFloat
    let color: Color
    
    init(dotSize: CGFloat = 1, spacing: CGFloat = 16, color: Color = .black) {
        self.dotSize = dotSize
        self.spacing = spacing
        self.color = color
    }
    
    var body: some View {
        GeometryReader { geometry in
            let columns = Int(geometry.size.width / spacing) + 1
            let rows = Int(geometry.size.height / spacing) + 1
            
            ZStack {
                ForEach(0..<rows, id: \.self) { row in
                    ForEach(0..<columns, id: \.self) { column in
                        Circle()
                            .fill(color)
                            .frame(width: dotSize, height: dotSize)
                            .position(
                                x: CGFloat(column) * spacing,
                                y: CGFloat(row) * spacing
                            )
                    }
                }
            }
        }
    }
}

/// Component to use the dot pattern as an overlay in light mode
struct DotPatternOverlay: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        if colorScheme == .light {
            DotPatternView(
                dotSize: 1.2,
                spacing: 20,
                color: Color.black.opacity(0.3)
            )
            .opacity(0.03)
            .blendMode(.overlay)
            .ignoresSafeArea()
        } else {
            // No pattern in dark mode
            EmptyView()
        }
    }
}

// MARK: - Preview
#if DEBUG
struct DotPatternView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(hex: "EEF2FF")
            
            DotPatternView(
                dotSize: 2,
                spacing: 20,
                color: .black
            )
            .opacity(0.1)
        }
        .frame(width: 200, height: 200)
        .previewLayout(.sizeThatFits)
    }
}
#endif
