//
//  ShiftStore.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//

import SwiftUI
import Combine

class ShiftStore: ObservableObject {
    @Published var shifts: [Shift] = []
    @Published var allEmployees: [Employee] = []
    
    // Cloud sync status
    @Published var isSyncing: Bool = false
    @Published var lastSyncTime: Date?
    @Published var syncError: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Setup would include code to load any locally saved shifts
        // and initialize cloud sync listeners
    }
    
    func startShift(customerName: String, address: String) -> Shift {
        let newShift = Shift(customerName: customerName, address: address)
        shifts.append(newShift)
        syncShiftToCloud(newShift)
        return newShift
    }
    
    func endShift(_ shift: Shift) {
        // Find the shift by ID and update it
        if let idx = shifts.firstIndex(where: { $0.id == shift.id }) {
            // Set the end time to now
            shifts[idx].endTime = Date()
            
            // Log for debugging
            print("Ending shift: \(shifts[idx].customerName), ID: \(shifts[idx].id)")
            print("End time set to: \(String(describing: shifts[idx].endTime))")
            
            // Verify the isEnded property now returns true
            print("Is shift ended: \(shifts[idx].isEnded)")
            
            syncShiftToCloud(shifts[idx])
            
            objectWillChange.send()
        } else {
            print("Error: Could not find shift with ID: \(shift.id) to end it")
        }
    }
    
    func addCar(to shift: Shift,
                licensePlate: String,
                make: String,
                model: String,
                color: String,
                location: String,
                parkedBy: Employee?,
                photo: UIImage? = nil,
                latitude: Double? = nil,
                longitude: Double? = nil) {
        guard let idx = shifts.firstIndex(where: { $0.id == shift.id }) else { return }
        let newCar = Car(
            photo: photo,
            licensePlate: licensePlate,
            make: make,
            model: model,
            color: color,
            locationParked: location,
            parkedBy: parkedBy,
            parkingLatitude: latitude,
            parkingLongitude: longitude
        )
        shifts[idx].cars.append(newCar)
        if let updatedShift = shifts.first(where: { $0.id == shift.id }) {
            syncShiftToCloud(updatedShift)
        }
    }
    
    func returnCar(in shift: Shift, car: Car) {
        guard let shiftIdx = shifts.firstIndex(where: { $0.id == shift.id }) else { return }
        guard let carIdx = shifts[shiftIdx].cars.firstIndex(where: { $0.id == car.id }) else { return }
        shifts[shiftIdx].cars[carIdx].isReturned = true
        shifts[shiftIdx].cars[carIdx].departureTime = Date()
        if let updatedShift = shifts.first(where: { $0.id == shift.id }) {
            syncShiftToCloud(updatedShift)
        }
    }
    
    // Creates a random-colored employee and adds them
    func addEmployee(name: String) {
        let randomColor = Color(
            hue: Double.random(in: 0...1),
            saturation: 0.7,
            brightness: 0.9
        )
        let employee = Employee(name: name, color: randomColor)
        allEmployees.append(employee)
    }
    
    // Adds employee to a specific shift
    func addEmployeeToShift(name: String, shift: Shift) {
        // Create the employee
        let randomColor = Color(
            hue: Double.random(in: 0...1),
            saturation: 0.7,
            brightness: 0.9
        )
        let employee = Employee(name: name, color: randomColor)
        
        // Add to global employees list
        allEmployees.append(employee)
        
        // Add to the specific shift
        guard let shiftIdx = shifts.firstIndex(where: { $0.id == shift.id }) else { return }
        shifts[shiftIdx].employees.append(employee)
        
        // Sync the changes
        if let updatedShift = shifts.first(where: { $0.id == shift.id }) {
            syncShiftToCloud(updatedShift)
        }
    }
    
    // Find a shift by its code
    func findShiftByCode(_ code: String) -> Shift? {
        return shifts.first { $0.shiftCode.uppercased() == code.uppercased() }
    }
    
    // MARK: - Cloud Integration Methods
    
    // This would normally integrate with Firebase/Firestore
    // For now, we'll simulate with placeholder methods
    
    func syncShiftToCloud(_ shift: Shift) {
        // In a real implementation, this would send the shift data to Firebase
        isSyncing = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isSyncing = false
            self.lastSyncTime = Date()
            // In a real app, we'd check for errors during the sync
        }
    }
    
    func fetchShiftFromCloud(byCode code: String, completion: @escaping (Result<Shift?, Error>) -> Void) {
        // In a real implementation, this would query Firebase for the shift
        isSyncing = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isSyncing = false
            
            // For demo purposes, just check our local shifts
            if let shift = self.findShiftByCode(code) {
                completion(.success(shift))
            } else {
                // Create a custom error
                let error = NSError(domain: "com.valet.app", code: 404, userInfo: [
                    NSLocalizedDescriptionKey: "Shift with code \(code) not found"
                ])
                completion(.failure(error))
            }
        }
    }
    
    // Setup listeners for cloud updates (would use Firebase listeners in real app)
    func setupCloudListeners() {
        // In a real implementation, this would set up Firebase listeners
        // to update the app in real-time when changes occur in the cloud
    }
}
