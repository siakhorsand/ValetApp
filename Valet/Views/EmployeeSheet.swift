//
//  EmployeeSheet.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//
// EmployeeSheet.swift
import SwiftUI

struct EmployeeSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var shiftStore: ShiftStore

    @State private var newEmployeeName = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Employees")
                .font(.headline)
                .padding(.top, 20)

            List {
                ForEach(shiftStore.allEmployees) { emp in
                    HStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(emp.color)
                            .frame(width: 20, height: 20)
                        Text(emp.name)
                    }
                }
            }
            .frame(height: 200) // scrollable area

            HStack {
                TextField("New Employee Name", text: $newEmployeeName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Add") {
                    guard !newEmployeeName.isEmpty else { return }
                    shiftStore.addEmployee(name: newEmployeeName)
                    newEmployeeName = ""
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)

            Spacer()

            Button("Done") {
                dismiss()
            }
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .frame(height: 400)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.8))
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding()
    }
}
