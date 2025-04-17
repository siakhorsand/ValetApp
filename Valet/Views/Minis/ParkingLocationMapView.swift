import SwiftUI
import MapKit
import CoreLocation

struct MapLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var locationUpdated = false // Use a bool flag to trigger updates
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
        locationUpdated.toggle() // Toggle to trigger updates
        locationManager.stopUpdatingLocation() // Stop after getting first good location
    }
}

struct ParkingLocationMapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region: MKCoordinateRegion
    @Binding var coordinate: CLLocationCoordinate2D?
    let carInfo: String
    let isEditable: Bool
    let accentColor: Color
    
    @State private var locations: [MapLocation] = []
    @State private var isPresentingConfirmation = false
    @State private var mapType: MKMapType = .standard
    @State private var hasInitializedUserLocation = false
    
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
            // Use conditional compilation for Map API based on iOS version
            if #available(iOS 17.0, *) {
                // Modern Map API for iOS 17+
                ZStack {
                    Map(initialPosition: MapCameraPosition.region(region)) {
                        // Show user location
                        UserAnnotation()
                        
                        // Show all map annotations
                        ForEach(getMapAnnotations()) { location in
                            Annotation(location.title, coordinate: location.coordinate) {
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
                    }
                    .mapStyle(mapType == .standard ? .standard : 
                             mapType == .hybrid ? .hybrid : 
                             .imagery)
                    .mapControls {
                        // Add standard map controls
                        MapUserLocationButton()
                        MapCompass()
                        MapScaleView()
                    }
                    
                    // Overlay for tap handling (only if editable)
                    if isEditable {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture { tapLocation in
                                // This is an approximation as we can't directly convert screen coordinates 
                                // to map coordinates in SwiftUI without UIKit
                                let mapSize = UIScreen.main.bounds.size
                                let tapCoordinate = convertPointToCoordinate(point: tapLocation, mapSize: mapSize)
                                
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
                    }
                }
                .onAppear {
                    // Update with user location when it becomes available
                    if coordinate == nil && !hasInitializedUserLocation {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            if let userLocation = locationManager.userLocation {
                                region = MKCoordinateRegion(
                                    center: userLocation,
                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                )
                                hasInitializedUserLocation = true
                            }
                        }
                    }
                }
                .onValueChange(of: locationManager.locationUpdated) { oldValue, newValue in
                    // Update region when user location changes (if we haven't set a custom location yet)
                    if coordinate == nil && !hasInitializedUserLocation, let userLocation = locationManager.userLocation {
                        region = MKCoordinateRegion(
                            center: userLocation,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                        hasInitializedUserLocation = true
                    }
                }
            } else {
                // Legacy Map API for iOS 16 and earlier
                Map(coordinateRegion: $region,
                    interactionModes: .all,
                    showsUserLocation: true,
                    annotationItems: getMapAnnotations()) { location in
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
                .onAppear {
                    // Update with user location when it becomes available
                    if coordinate == nil && !hasInitializedUserLocation {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            if let userLocation = locationManager.userLocation {
                                region = MKCoordinateRegion(
                                    center: userLocation,
                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                )
                                hasInitializedUserLocation = true
                            }
                        }
                    }
                }
                .onValueChange(of: locationManager.locationUpdated) { oldValue, newValue in
                    // Update region when user location changes (if we haven't set a custom location yet)
                    if coordinate == nil && !hasInitializedUserLocation, let userLocation = locationManager.userLocation {
                        region = MKCoordinateRegion(
                            center: userLocation,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                        hasInitializedUserLocation = true
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
        .onValueChange(of: mapType) { oldValue, newValue in
            // Map style is automatically updated in iOS 17+ through the .mapStyle() modifier
            // For iOS 16 and earlier, there's no direct way to update the map type in SwiftUI
            if #available(iOS 17.0, *) {
                // No need for additional code - the binding in .mapStyle() handles it
            } else {
                // For older iOS versions, we'd need a UIKit workaround if truly needed
                UIView.animate(withDuration: 0.3) {
                    // This is just a placeholder - not functional in pure SwiftUI for older iOS
                }
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

// Private internal implementation for iOS < 17
private struct ValueChangeModifier<V: Equatable, Content: View>: View {
    let content: Content
    let action: (V, V) -> Void
    
    @State private var storedValue: V
    let newValue: V
    
    init(value: V, action: @escaping (V, V) -> Void, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.action = action
        self._storedValue = State(initialValue: value)
        self.newValue = value
    }
    
    var body: some View {
        content
            .onChange(of: newValue) { oldValue, updatedValue in
                if storedValue != updatedValue {
                    action(storedValue, updatedValue)
                    storedValue = updatedValue
                }
            }
    }
}
