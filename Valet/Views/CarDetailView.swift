//
//  CarDetailView.swift
//  Valet
//
//  Created by Sia Khorsand on 1/15/25.
//
import SwiftUI
struct CarDetailView: View {
    let car: Car

    var body: some View {
        VStack(spacing: 20) {
            if let photo = car.photo {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(10)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Make & Model: \(car.make) \(car.model)")
                    .font(.headline)
                Text("License Plate: \(car.licensePlate)")
                Text("Color: \(car.color)")
                Text("Location: \(car.locationParked)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)

            Spacer()
        }
        .padding()
        .navigationTitle("Car Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
