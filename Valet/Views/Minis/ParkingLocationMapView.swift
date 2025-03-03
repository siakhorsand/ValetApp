//
//  ParkingLocationMapView.swift
//  Valet
//
//  Created by Claude on 3/3/2025.
//

import SwiftUI
import MapKit

struct MapLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
}

struct ParkingLocationMapView: View {
    @State private var region: MKCoordinateRegion
    @Binding var coordinate: CLLocationCoordinate2D?
    let carInfo: String
    let isEditable: Bool
    let accentColor: Color
    
    @State private var locations: [MapLocation] = []
    @State private var isPresentingConfirmation = false
    @State private var mapType: MKMapType = .standard
    
    init(coordinate: Binding<CLLocationCoordinate2D?>, carInfo: String, isEditable: Bool = false, accentColor: Color = ValetTheme.primary) {
        self._coordinate = coordinate
        self.carInfo = carInfo
        self.isEditable = isEditable
        self.accentColor = accentColor
        
        // Set initial region based on provided coordinate or default to a general location
        if let coord = coordinate.wrappedValue {
            self._region = State(initialValue: MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            ))
        } else {
            // Default to a general area (this could be the current location in a real app)
            self._region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), // Los Angeles
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
    }
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, annotationItems: getMapAnnotations()) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    VStack {
                        Image(systemName: "car.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(accentColor)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                        
                        if location.title != "New Location" {
                            Text(location.title)
                                .font(.caption)
                                .padding(4)
                                .background(Color.black.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                    }
                }
            }
            .onTapGesture { tapLocation in
                guard isEditable else { return }
                
                // Convert tap location to coordinates
                let tapPoint = tapLocation
                let mapSize = UIScreen.main.bounds.size
                
                // Create CLLocationCoordinate from tap point on map
                let tapCoordinate = convertPointToCoordinate(point: tapPoint, mapSize: mapSize)
                
                // Clear previous temporary locations
                locations.removeAll()
                
                // Add new temporary location
                let newLocation = MapLocation(
                    coordinate: tapCoordinate,
                    title: "New Location"
                )
                locations.append(newLocation)
                
                // Ask for confirmation
                isPresentingConfirmation = true
            }
            
            // Controls overlay
            VStack {
                if isEditable {
                    // Pin drop instruction if editable
                    Text("Tap to place a pin where the car is parked")
                        .font(.caption)
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                // Map controls
                HStack {
                    // Map type picker
                    Menu {
                        Button(action: { mapType = .standard }) {
                            Label("Standard", systemImage: "map")
                        }
                        Button(action: { mapType = .hybrid }) {
                            Label("Hybrid", systemImage: "map.fill")
                        }
                        Button(action: { mapType = .satellite }) {
                            Label("Satellite", systemImage: "photo")
                        }
                    } label: {
                        Image(systemName: "map")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Zoom controls
                    VStack(spacing: 10) {
                        Button(action: {
                            withAnimation {
                                zoomIn()
                            }
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            withAnimation {
                                zoomOut()
                            }
                        }) {
                            Image(systemName: "minus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .padding(.top, 10)
        }
        .alert("Save this location?", isPresented: $isPresentingConfirmation) {
            Button("Cancel", role: .cancel) {
                locations.removeAll()
            }
            
            Button("Save") {
                if let location = locations.first {
                    coordinate = location.coordinate
                }
                locations.removeAll()
            }
        } message: {
            Text("Do you want to save this as the parking location for this car?")
        }
        .onChange(of: mapType) { newMapType in
            // Apply new map type
            UIView.animate(withDuration: 0.3) {
                // In a real implementation, you would update the map type
                // For SwiftUI's Map, this would require different handling
            }
        }
    }
    
    // Get all map annotations (fixed + temporary)
    private func getMapAnnotations() -> [MapLocation] {
        var annotations = locations
        
        // Add the fixed coordinate if available
        if let coord = coordinate {
            annotations.append(MapLocation(coordinate: coord, title: carInfo))
        }
        
        return annotations
    }
    
    // Helper to convert tap point to coordinate
    private func convertPointToCoordinate(point: CGPoint, mapSize: CGSize) -> CLLocationCoordinate2D {
        // Calculate proportional position in the map view
        let x = Double(point.x / mapSize.width)
        let y = Double(point.y / mapSize.height)
        
        // Calculate longitude span and latitude span
        let longitudeDelta = region.span.longitudeDelta
        let latitudeDelta = region.span.latitudeDelta
        
        // Calculate the actual longitude and latitude based on proportional position
        let longitude = region.center.longitude - (longitudeDelta / 2.0) + (longitudeDelta * x)
        let latitude = region.center.latitude + (latitudeDelta / 2.0) - (latitudeDelta * y)
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // Zoom control methods
    private func zoomIn() {
        var newRegion = region
        newRegion.span = MKCoordinateSpan(
            latitudeDelta: region.span.latitudeDelta * 0.5,
            longitudeDelta: region.span.longitudeDelta * 0.5
        )
        region = newRegion
    }
    
    private func zoomOut() {
        var newRegion = region
        newRegion.span = MKCoordinateSpan(
            latitudeDelta: region.span.latitudeDelta * 2.0,
            longitudeDelta: region.span.longitudeDelta * 2.0
        )
        region = newRegion
    }
}
