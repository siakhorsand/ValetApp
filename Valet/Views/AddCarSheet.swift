//
//  AddCarSheet.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//

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
    @State private var showCamera = false
    @State private var carPhoto: UIImage?

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    ValetTheme.background,
                    ValetTheme.surfaceVariant.opacity(0.3),
                    ValetTheme.background
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Stylish header
                VStack(spacing: 10) {
                    Image(systemName: "car.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(ValetTheme.primary)
                        .padding(.top, 20)
                    
                    Text("Add New Car")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(ValetTheme.onSurface)
                }
                .padding(.bottom, 10)
                
                // Input fields with improved styling
                ScrollView {
                    VStack(spacing: 20) {
                        // Photo section
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "camera")
                                    .foregroundColor(ValetTheme.primary)
                                Text("PHOTO")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(ValetTheme.primary)
                            }
                            
                            Button {
                                showCamera = true
                            } label: {
                                Group {
                                    if let photo = carPhoto {
                                        Image(uiImage: photo)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 150)
                                            .clipped()
                                    } else {
                                        ZStack {
                                            Rectangle()
                                                .fill(ValetTheme.surfaceVariant)
                                                .frame(height: 150)
                                            
                                            VStack(spacing: 10) {
                                                Image(systemName: "camera.fill")
                                                    .font(.system(size: 30))
                                                
                                                Text("Tap to add photo")
                                                    .font(.subheadline)
                                            }
                                            .foregroundColor(ValetTheme.textSecondary)
                                        }
                                    }
                                }
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(ValetTheme.primary.opacity(0.6), lineWidth: 2)
                                )
                            }
                        }
                        
                        // Form fields with consistent styling
                        StylishFormField(
                            icon: "number.square.fill",
                            label: "LICENSE PLATE",
                            text: $licensePlate
                        )
                        .autocapitalization(.allCharacters)
                        
                        HStack(spacing: 15) {
                            StylishFormField(
                                icon: "car.fill",
                                label: "MAKE",
                                text: $make
                            )
                            .frame(maxWidth: .infinity)
                            
                            StylishFormField(
                                icon: "car.2.fill",
                                label: "MODEL",
                                text: $model
                            )
                            .frame(maxWidth: .infinity)
                        }
                        
                        StylishFormField(
                            icon: "paintpalette.fill",
                            label: "COLOR",
                            text: $color
                        )
                        
                        StylishFormField(
                            icon: "location.fill",
                            label: "LOCATION PARKED",
                            text: $location
                        )
                        
                        // Employee selection with matching style
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(ValetTheme.primary)
                                Text("PARKED BY")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(ValetTheme.primary)
                            }
                            
                            Menu {
                                Button("None") {
                                    selectedEmployee = nil
                                }
                                
                                ForEach(shiftStore.allEmployees, id: \.id) { emp in
                                    Button(emp.name) {
                                        selectedEmployee = emp
                                    }
                                }
                            } label: {
                                HStack {
                                    if let employee = selectedEmployee {
                                        HStack {
                                            Circle()
                                                .fill(employee.color)
                                                .frame(width: 16, height: 16)
                                            
                                            Text(employee.name)
                                                .foregroundColor(ValetTheme.onSurface)
                                        }
                                    } else {
                                        Text("Select employee")
                                            .foregroundColor(ValetTheme.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(ValetTheme.textSecondary)
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
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 15) {
                    Button(action: {
                        addNewCar()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Car")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            isFormValid ?
                                ValetTheme.primaryGradient :
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.4)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                        )
                        .cornerRadius(15)
                        .shadow(color: isFormValid ? ValetTheme.primary.opacity(0.3) : Color.clear, radius: 5, x: 0, y: 3)
                    }
                    .disabled(!isFormValid)
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(ValetTheme.textSecondary)
                    .padding(.vertical, 10)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(image: $carPhoto)
        }
        .preferredColorScheme(.dark)
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    // Form validation
    private var isFormValid: Bool {
        !licensePlate.isEmpty &&
        !make.isEmpty &&
        !model.isEmpty &&
        !color.isEmpty &&
        !location.isEmpty
    }
    
    // Add car and close the sheet
    private func addNewCar() {
        guard isFormValid else { return }
        
        shiftStore.addCar(
            to: shift,
            licensePlate: licensePlate,
            make: make,
            model: model,
            color: color,
            location: location,
            parkedBy: selectedEmployee
        )
        
        // Success haptic
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        dismiss()
    }
    
    // Hide keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Supporting Views

// Stylish Form Field
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
