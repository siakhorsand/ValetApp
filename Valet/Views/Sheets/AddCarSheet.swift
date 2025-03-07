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
    @EnvironmentObject var userManager: UserManager
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
                            
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundColor(ValetTheme.primary)
                                    Text("MAP LOCATION")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(ValetTheme.primary)
                                    
                                    Spacer()
                                    
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
                                
                                MiniMapView(
                                    coordinate: $coordinate,
                                    carInfo: "\(make) \(model)",
                                    height: 130
                                ) {
                                    showMapSheet = true
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(ValetTheme.primary)
                                Text("PARKED BY")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(ValetTheme.primary)
                            }
                            
                            if let user = userManager.currentUser {
                                let existingEmployee = shiftStore.allEmployees.first(where: { $0.name == user.name })
                                
                                HStack {
                                    if let employee = existingEmployee {
                                        HStack {
                                            Circle()
                                                .fill(employee.color)
                                                .frame(width: 16, height: 16)
                                            
                                            Text(employee.name)
                                                .foregroundColor(ValetTheme.onSurface)
                                        }
                                    } else {
                                        Text(user.name)
                                            .foregroundColor(ValetTheme.onSurface)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("From Profile")
                                        .font(.caption2)
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 8)
                                        .background(ValetTheme.primary.opacity(0.2))
                                        .cornerRadius(4)
                                        .foregroundColor(ValetTheme.primary.opacity(0.8))
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
        .onAppear {
            if let user = userManager.currentUser {
                let existingEmployee = shiftStore.allEmployees.first(where: { $0.name == user.name })
                selectedEmployee = existingEmployee
                
            }
        }
    }
    
    // Form validation
    private var isFormValid: Bool {
        !licensePlate.isEmpty &&
        !make.isEmpty &&
        !model.isEmpty &&
        !color.isEmpty &&
        !location.isEmpty &&
        userManager.currentUser != nil
    }
    

    private func addNewCar() {
        guard isFormValid, let user = userManager.currentUser else { return }
        

        var employee: Employee
        if let existingEmployee = selectedEmployee {
            employee = existingEmployee
        } else {
            let randomColor = Color(
                hue: Double.random(in: 0...1),
                saturation: 0.7,
                brightness: 0.9
            )
            employee = Employee(name: user.name, color: randomColor)
            
            shiftStore.allEmployees.append(employee)
        }
        
        // Create the car with location coordinates
        let newCar = Car(
            photo: carPhoto,
            licensePlate: licensePlate,
            make: make,
            model: model,
            color: color,
            locationParked: location,
            parkedBy: employee,
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

#if DEBUG
struct AddCarSheet_Previews: PreviewProvider {
    static var previews: some View {
        let shiftStore = ShiftStore(withDemoData: true)
        let shift = shiftStore.shifts.first!
        
        return Group {
            AddCarSheet(shift: shift)
                .environmentObject(shiftStore)
                .environmentObject(UserManager.shared)
                .preferredColorScheme(.dark)
        }
    }
}
#endif
