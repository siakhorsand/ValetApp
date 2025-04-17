import SwiftUI
import MapKit

struct MiniMapView: View {
    @Binding var coordinate: CLLocationCoordinate2D?
    let carInfo: String
    let accentColor: Color
    let height: CGFloat
    let onTap: (() -> Void)?
    
    @State private var region: MKCoordinateRegion
    @State private var previousLatitude: Double?
    @State private var previousLongitude: Double?
    
    init(coordinate: Binding<CLLocationCoordinate2D?>,
         carInfo: String,
         accentColor: Color = ValetTheme.primary,
         height: CGFloat = 150,
         onTap: (() -> Void)? = nil) {
        
        self._coordinate = coordinate
        self.carInfo = carInfo
        self.accentColor = accentColor
        self.height = height
        self.onTap = onTap
        
        // Set initial region based on provided coordinate or default to a general location
        if let coord = coordinate.wrappedValue {
            self._region = State(initialValue: MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003) // Very zoomed in
            ))
            self._previousLatitude = State(initialValue: coord.latitude)
            self._previousLongitude = State(initialValue: coord.longitude)
        } else {
            // Default to a general area
            self._region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), // Los Angeles
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
            self._previousLatitude = State(initialValue: nil)
            self._previousLongitude = State(initialValue: nil)
        }
    }
    
    var body: some View {
        ZStack {
            if let coord = coordinate {
                // Map with pin
                LegacyMapView(
                    region: $region,
                    coordinate: coord,
                    carInfo: carInfo,
                    accentColor: accentColor
                )
                .onAppear {
                    // Update region on appear
                    updateRegion()
                }
                
                // Expand button if onTap is provided
                if onTap != nil {
                    VStack {
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                onTap?()
                            }) {
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(accentColor.opacity(0.8))
                                    .clipShape(Circle())
                                    .shadow(radius: 1)
                            }
                            .padding(8)
                        }
                        
                        Spacer()
                    }
                }
            } else {
                // Placeholder when no coordinates
                ZStack {
                    Color(UIColor.systemGray5)
                    
                    VStack(spacing: 8) {
                        Image(systemName: "map")
                            .font(.system(size: 24))
                            .foregroundColor(Color(UIColor.systemGray2))
                        
                        Text("No Location")
                            .font(.caption)
                            .foregroundColor(Color(UIColor.systemGray))
                    }
                }
            }
        }
        .frame(height: height)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
        .onTapGesture {
            onTap?()
        }
        // Check for coordinate changes in a way that works across iOS versions
        .onValueChange(of: coordinate?.latitude) { oldValue, newValue in
            updateRegion()
        }
        .onValueChange(of: coordinate?.longitude) { oldValue, newValue in
            updateRegion()
        }
    }
    
    private func updateRegion() {
        guard let coord = coordinate else { return }
        
        // Only update if the coordinates have actually changed
        if coord.latitude != previousLatitude || coord.longitude != previousLongitude {
            // Update the region with the current coordinate
            region = MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
            )
            
            // Update previous values
            previousLatitude = coord.latitude
            previousLongitude = coord.longitude
        }
    }
}

// Legacy Map implementation that works across iOS versions
struct LegacyMapView: View {
    @Binding var region: MKCoordinateRegion
    let coordinate: CLLocationCoordinate2D
    let carInfo: String
    let accentColor: Color
    
    @State private var previousLatitude: Double = 0
    @State private var previousLongitude: Double = 0
    
    var body: some View {
        if #available(iOS 17.0, *) {
            Map(initialPosition: MapCameraPosition.region(region)) {
                Annotation(carInfo, coordinate: coordinate) {
                    VStack(spacing: 0) {
                        Image(systemName: "car.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(accentColor)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                }
            }
            .onAppear {
                previousLatitude = coordinate.latitude
                previousLongitude = coordinate.longitude
            }
            .onChange(of: coordinate.latitude) { _, newValue in
                if previousLatitude != newValue {
                    updateRegion()
                    previousLatitude = newValue
                }
            }
            .onChange(of: coordinate.longitude) { _, newValue in
                if previousLongitude != newValue {
                    updateRegion()
                    previousLongitude = newValue
                }
            }
            .allowsHitTesting(false)
        } else {
            Map(coordinateRegion: $region,
                interactionModes: [],
                showsUserLocation: false,
                annotationItems: [MapLocation(coordinate: coordinate, title: carInfo)]) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    VStack(spacing: 0) {
                        Image(systemName: "car.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(accentColor)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                }
            }
            .onAppear {
                previousLatitude = coordinate.latitude
                previousLongitude = coordinate.longitude
            }
            .onValueChange(of: coordinate.latitude) { oldValue, newValue in
                if oldValue != newValue {
                    updateRegion()
                }
            }
            .onValueChange(of: coordinate.longitude) { oldValue, newValue in
                if oldValue != newValue {
                    updateRegion()
                }
            }
        }
    }
    
    private func updateRegion() {
        region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
        )
    }
}
