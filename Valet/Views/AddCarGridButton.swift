//
//  AddCarGridButton.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//
import SwiftUI
struct AddCarGridButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(radius: 3)
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white)
            }
            .frame(height: 70)
        }
    }
}
