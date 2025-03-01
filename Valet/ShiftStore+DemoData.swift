
import SwiftUI

// Extension to ShiftStore for creating demo data
extension ShiftStore {
    
    // Call this function in init() to populate demo data
    func setupDemoData() {
        // Create team members
        let mazzy = Employee(name: "Mazzy", color: Color(hue: 0.55, saturation: 0.7, brightness: 0.9))
        let sia = Employee(name: "Sia", color: Color(hue: 0.9, saturation: 0.7, brightness: 0.9))
        let sam = Employee(name: "Sam", color: Color(hue: 0.1, saturation: 0.7, brightness: 0.9))
        
        allEmployees.append(contentsOf: [mazzy, sia, sam])
        
        // Create a past shift
        var demoShift = Shift(customerName: "Sunset Gala Event", address: "1250 Ocean Drive, Beverly Hills")
        
        // Set a past date (2 days ago)
        let calendar = Calendar.current
        if let pastDate = calendar.date(byAdding: .day, value: -2, to: Date()) {
            demoShift.startTime = pastDate
            demoShift.endTime = calendar.date(byAdding: .hour, value: 5, to: pastDate)
        }
        
        // Add employees to shift
        demoShift.employees = [mazzy, sia, sam]
        
        // Generate car makes and models
        let carData: [(make: String, models: [String])] = [
            ("BMW", ["330i", "X5", "M3", "740i", "X3"]),
            ("Mercedes", ["E350", "S500", "GLE", "C300", "GLC"]),
            ("Tesla", ["Model S", "Model 3", "Model Y", "Model X"]),
            ("Audi", ["A4", "Q5", "S7", "A6", "Q7"]),
            ("Lexus", ["ES350", "RX350", "LS500", "NX300"]),
            ("Porsche", ["911", "Cayenne", "Taycan", "Macan"]),
            ("Range Rover", ["Sport", "Evoque", "Velar", "Defender"]),
            ("Lamborghini", ["Urus", "Huracan"]),
            ("Ferrari", ["Roma", "SF90", "F8"]),
            ("Bentley", ["Continental GT", "Bentayga"]),
            ("Rolls-Royce", ["Ghost", "Cullinan", "Phantom"]),
            ("Maserati", ["Levante", "Ghibli", "Quattroporte"]),
            ("Jaguar", ["F-Pace", "XF", "I-Pace"]),
            ("Cadillac", ["Escalade", "XT5", "CT5"])
        ]
        
        // Colors
        let carColors = ["Black", "White", "Silver", "Gray", "Red", "Blue", "Champagne", "Dark Blue", "Green", "Brown", "Burgundy"]
        
        // Locations
        let locations = ["Front Row A", "Front Row B", "VIP Section", "North Lot", "South Lot", "Valet Area 1", "Valet Area 2", "East Entrance", "West Entrance", "Lower Level", "Upper Deck"]
        
        // Letter prefixes for license plates
        let licensePrefixes = ["ABC", "XYZ", "LMN", "PQR", "STU", "JKL", "DEF", "GHI", "WOW", "CAR", "VIP"]
        
        // Add 22 cars to the shift
        var generatedCars: [Car] = []
        
        // Function to generate a random license plate
        func randomLicensePlate() -> String {
            let prefix = licensePrefixes.randomElement() ?? "ABC"
            let numbers = String(format: "%03d", Int.random(in: 100...999))
            return prefix + numbers
        }
        
        // Add 22 cars
        for i in 1...22 {
            // Select random car details
            let carType = carData.randomElement()!
            let model = carType.models.randomElement()!
            let color = carColors.randomElement()!
            let location = locations.randomElement()!
            let licensePlate = randomLicensePlate()
            
            // Determine who parked it (round-robin assignment)
            let parkingStaff: [Employee] = [mazzy, sia, sam]
            let parkedBy = parkingStaff[i % parkingStaff.count]
            
            // Create arrival time (staggered throughout the event)
            var arrivalOffset = Double(i * 5) // 5 minutes between cars
            if i > 10 {
                arrivalOffset = Double((i - 10) * 7) + 60 // Later arrivals more spread out
            }
            
            let arrivalTime = demoShift.startTime.addingTimeInterval(arrivalOffset * 60)
            
            // Most cars should be returned, but leave a few active
            var departureTime: Date? = nil
            var isReturned = false
            
            if i <= 18 { // 18 out of 22 cars returned
                let stayDuration = Double.random(in: 90...240) // 1.5 to 4 hours
                departureTime = arrivalTime.addingTimeInterval(stayDuration * 60)
                isReturned = true
            }
            
            // Create car
            let car = Car(
                photo: nil,
                licensePlate: licensePlate,
                make: carType.make,
                model: model,
                color: color,
                locationParked: location,
                arrivalTime: arrivalTime,
                departureTime: departureTime,
                isReturned: isReturned,
                parkedBy: parkedBy
            )
            
            generatedCars.append(car)
        }
        
        // Add cars to shift
        demoShift.cars = generatedCars
        
        // Add shift to store
        shifts.append(demoShift)
    }
}

// Update ShiftStore init method to create demo data
extension ShiftStore {
    // This class constructor override would normally be in the original ShiftStore.swift file
    // We're putting it here for clarity in the demo
    convenience init(withDemoData: Bool = true) {
        self.init()
        if withDemoData {
            setupDemoData()
        }
    }
}
