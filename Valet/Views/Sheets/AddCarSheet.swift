//
//  AddCarSheet.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//

import SwiftUI
import MapKit
import CoreLocation

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
    @State private var showMapSheet = false
    @State private var coordinate: CLLocationCoordinate2D?
    @State private var useDirectPhoto = false

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
                                // Show action sheet for camera options
                                useDirectPhoto = true
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
                                                
                                                Text("Tap to take photo")
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
                        
                        // Location field with map
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(ValetTheme.primary)
                                Text("LOCATION PARKED")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(ValetTheme.primary)
                            }
                            
                            TextField("", text: $location)
                                .placeholder(when: location.isEmpty) {
                                    Text("Enter location parked")
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
                            
                            // Mini map preview
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundColor(ValetTheme.primary)
                                    Text("MAP LOCATION")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(ValetTheme.primary)
                                    
                                    Spacer()
                                    
                                    // Status indicator
                                    if coordinate != nil {
                                        HStack(spacing: 4) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(ValetTheme.success)
                                                .font(.caption)
                                            
                                            Text("Location set")
                                                .font(.caption)
                                                .foregroundColor(ValetTheme.success)
                                        }
                                    } else {
                                        Button(action: {
                                            showMapSheet = true
                                        }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "plus.circle.fill")
                                                    .font(.caption)
                                                
                                                Text("Add pin")
                                                    .font(.caption)
                                            }
                                            .foregroundColor(ValetTheme.primary)
                                        }
                                    }
                                }
                                
                                // Mini map view - tappable to open full map
                                MiniMapView(
                                    coordinate: $coordinate,
                                    carInfo: "\(make) \(model)",
                                    height: 130
                                ) {
                                    showMapSheet = true
                                }
                            }
                        }
                        
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
            if useDirectPhoto {
                DirectCameraView(image: $carPhoto, isPresented: $showCamera)
                    .preferredColorScheme(.dark)
            } else {
                ImagePicker(image: $carPhoto)
            }
        }
        .sheet(isPresented: $showMapSheet) {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        showMapSheet = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(ValetTheme.onSurface)
                            .padding(10)
                    }
                    
                    Spacer()
                    
                    Text("Set Parking Location")
                        .font(.headline)
                        .foregroundColor(ValetTheme.primary)
                    
                    Spacer()
                    
                    Button("Done") {
                        showMapSheet = false
                    }
                    .font(.headline)
                    .foregroundColor(ValetTheme.primary)
                    .padding(10)
                }
                .padding(.horizontal)
                .background(ValetTheme.surfaceVariant)
                
                // Map
                ParkingLocationMapView(
                    coordinate: $coordinate,
                    carInfo: "\(make) \(model) - \(licensePlate)",
                    isEditable: true
                )
            }
            .preferredColorScheme(.dark)
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
        
        // Create the car with location coordinates
        let newCar = Car(
            photo: carPhoto,
            licensePlate: licensePlate,
            make: make,
            model: model,
            color: color,
            locationParked: location,
            parkedBy: selectedEmployee,
            parkingLatitude: coordinate?.latitude,
            parkingLongitude: coordinate?.longitude
        )
        
        // Add to the shift
        guard let shiftIdx = shiftStore.shifts.firstIndex(where: { $0.id == shift.id }) else { return }
        shiftStore.shifts[shiftIdx].cars.append(newCar)
        
        if let updatedShift = shiftStore.shifts.first(where: { $0.id == shift.id }) {
            shiftStore.syncShiftToCloud(updatedShift)
        }
        
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
