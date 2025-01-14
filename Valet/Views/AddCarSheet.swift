//
//  AddCArView.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//

// AddCarSheet.swift
import SwiftUI

struct AddCarSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var shiftStore: ShiftStore
    let shift: Shift

    @State private var licensePlate = ""
    @State private var make = ""
    @State private var model = ""
    @State private var color = ""
    @State private var location = ""
    @State private var selectedEmployee: Employee?

    var body: some View {
        VStack(spacing: 20) {
            Text("Add a Car")
                .font(.headline)
                .padding(.top, 20)

            VStack(spacing: 15) {
                TextField("License Plate", text: $licensePlate)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Make", text: $make)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Model", text: $model)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Color", text: $color)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Location Parked", text: $location)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                // Picker for employee
                Picker("Parked by", selection: $selectedEmployee) {
                    Text("None").tag(Employee?.none)
                    ForEach(shiftStore.allEmployees, id: \.id) { emp in
                        Text(emp.name).tag(Employee?.some(emp))
                    }
                }
                .pickerStyle(.menu)
            }
            .padding(.horizontal)
            .frame(maxWidth: 300)
            .padding()

            Spacer()

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

                Button("Add Car") {
                    guard !licensePlate.isEmpty,
                          !make.isEmpty,
                          !model.isEmpty,
                          !color.isEmpty,
                          !location.isEmpty
                    else { return }

                    shiftStore.addCar(
                        to: shift,
                        licensePlate: licensePlate,
                        make: make,
                        model: model,
                        color: color,
                        location: location,
                        parkedBy: selectedEmployee
                    )
                    dismiss()
                }
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(
                    (!licensePlate.isEmpty && !make.isEmpty && !model.isEmpty &&
                     !color.isEmpty && !location.isEmpty)
                    ? Color.blue : Color.gray
                )
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .frame(height: 450)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.8))
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding()
    }
}
