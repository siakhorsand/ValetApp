//
//  CarDetailView.swift
//  Valet
//
//  Created by Sia Khorsand on 1/15/25.
//
import SwiftUI
import MapKit

struct CarDetailView: View {
    let car: Car
    @State private var mapCoordinate: CLLocationCoordinate2D?
    @State private var showFullScreenMap = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let photo = car.photo {
                    Image(uiImage: photo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 5)
                        .padding(.horizontal)
                }

                // Car info card
                VStack(alignment: .leading, spacing: 12) {
                    Text("\(car.make) \(car.model)")
                        .font(.title2)
                        .bold()
                        .foregroundColor(ValetTheme.onSurface)
                    
                    Divider()
                        .background(ValetTheme.primary.opacity(0.5))
                    
                    DetailRow(title: "License Plate", value: car.licensePlate)
                    DetailRow(title: "Color", value: car.color)
                    DetailRow(title: "Location Description", value: car.locationParked)
                    
                    if car.hasCoordinates {
                        DetailRow(title: "Map Location", value: "Available (tap to view)")
                    }
                }
                .padding()
                .background(ValetTheme.surfaceVariant)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // Map view if coordinates are available
                // Map view if coordinates are available
                if car.hasCoordinates, let lat = car.parkingLatitude, let lon = car.parkingLongitude {
                    VStack(alignment: .leading) {
                        Text("PARKING LOCATION")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(ValetTheme.primary)
                            .padding(.horizontal)
                        
                        // Initialize coordinate state on first load
                        let _ = {
                            if mapCoordinate == nil {
                                mapCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                            }
                        }()
                        
                        // Interactive map
                        ZStack {
                            ParkingLocationMapView(
                                coordinate: $mapCoordinate,
                                carInfo: "\(car.make) \(car.model)",
                                isEditable: false,
                                accentColor: ValetTheme.primary
                            )
                            .frame(height: 220)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                            
                            // Full-screen button
                            VStack {
                                HStack {
                                    Spacer()
                                    
                                    Button {
                                        showFullScreenMap = true
                                    } label: {
                                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .background(ValetTheme.primary.opacity(0.8))
                                            .clipShape(Circle())
                                            .shadow(radius: 2)
                                    }
                                    .padding(10)
                                }
                                
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Timing information
                VStack(alignment: .leading, spacing: 8) {
                    Text("TIMING")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(ValetTheme.primary)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top) {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(ValetTheme.primary)
                                .frame(width: 20)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Arrival Time")
                                    .font(.subheadline)
                                    .foregroundColor(ValetTheme.textSecondary)
                                
                                Text(formatDateTime(car.arrivalTime))
                                    .font(.body)
                                    .foregroundColor(ValetTheme.onSurface)
                            }
                        }
                        
                        if let departureTime = car.departureTime {
                            HStack(alignment: .top) {
                                Image(systemName: "clock.arrow.2.circlepath")
                                    .foregroundColor(ValetTheme.success)
                                    .frame(width: 20)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Departure Time")
                                        .font(.subheadline)
                                        .foregroundColor(ValetTheme.textSecondary)
                                    
                                    Text(formatDateTime(departureTime))
                                        .font(.body)
                                        .foregroundColor(ValetTheme.success)
                                    
                                    // Duration
                                    Text("Duration: \(calculateDuration(from: car.arrivalTime, to: departureTime))")
                                        .font(.caption)
                                        .foregroundColor(ValetTheme.textSecondary)
                                        .padding(.top, 2)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(ValetTheme.surfaceVariant)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                
                // Valet information (if available)
                if let employee = car.parkedBy {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("VALET INFORMATION")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(ValetTheme.primary)
                            .padding(.horizontal)
                        
                        HStack(spacing: 15) {
                            Circle()
                                .fill(employee.color)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text(employee.name.prefix(1).uppercased())
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .shadow(color: employee.color.opacity(0.3), radius: 5, x: 0, y: 3)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Parked by")
                                    .font(.subheadline)
                                    .foregroundColor(ValetTheme.textSecondary)
                                
                                Text(employee.name)
                                    .font(.headline)
                                    .foregroundColor(ValetTheme.onSurface)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(ValetTheme.surfaceVariant)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                }

                Spacer()
            }
            .padding(.vertical)
        }
        .navigationTitle("Car Details")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showFullScreenMap) {
            if let lat = car.parkingLatitude, let lon = car.parkingLongitude {
                VStack {
                    // Header
                    HStack {
                        Button {
                            showFullScreenMap = false
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(ValetTheme.onSurface)
                                .padding(10)
                                .background(ValetTheme.surfaceVariant)
                                .clipShape(Circle())
                        }
                        .padding(.leading)
                        
                        Spacer()
                        
                        Text("\(car.make) \(car.model) - \(car.licensePlate)")
                            .font(.headline)
                            .foregroundColor(ValetTheme.onSurface)
                        
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .background(ValetTheme.surfaceVariant)
                    
                    // Full screen map
                    ParkingLocationMapView(
                        coordinate: $mapCoordinate,
                        carInfo: "\(car.make) \(car.model) - \(car.licensePlate)",
                        isEditable: false,
                        accentColor: ValetTheme.primary
                    )
                }
                .preferredColorScheme(.dark)
                .onAppear {
                    if mapCoordinate == nil {
                        mapCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    }
                }
            }
        }
    }
    
    // Format date and time
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Calculate duration between dates
    private func calculateDuration(from startDate: Date, to endDate: Date) -> String {
        let components = Calendar.current.dateComponents([.hour, .minute], from: startDate, to: endDate)
        
        if let hours = components.hour, let minutes = components.minute {
            if hours > 0 {
                return "\(hours) hr \(minutes) min"
            } else {
                return "\(minutes) minutes"
            }
        }
        
        return "Unknown duration"
    }
}

// Helper components
struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(ValetTheme.textSecondary)
                .frame(width: 150, alignment: .leading)
            
            Text(value)
                .foregroundColor(ValetTheme.onSurface)
            
            Spacer()
        }
        .font(.subheadline)
    }
}
