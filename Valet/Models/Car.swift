//
//  Car.swift
//  Valet
//
//  Created by Sia Khorsand on 1/14/25.
//

import Foundation
import UIKit

struct Car: Identifiable {
    let id = UUID()
    let photo: UIImage?
    var licensePlate: String
    var make: String
    var model: String
    var color: String
    var locationParked: String
    var arrivalTime: Date = Date()
    var departureTime: Date?
    var isReturned: Bool = false
    var parkedBy: Employee? // Which employee parked the car
    var parkingLatitude: Double?
    var parkingLongitude: Double?
    
    var hasCoordinates: Bool {
        return parkingLatitude != nil && parkingLongitude != nil
    }
}
