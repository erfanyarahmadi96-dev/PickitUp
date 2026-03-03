import SwiftUI
import MapKit
import CoreLocation
internal import Combine

// MARK: - CLLocationCoordinate2D Equatable

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

// MARK: - Search Completer

class LocationSearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var results: [MKLocalSearchCompletion] = []
    @Published var queryFragment: String = "" {
        didSet { completer.queryFragment = queryFragment }
    }
    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = Array(completer.results.prefix(6))
    }
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        results = []
    }
}

// MARK: - LocationPickerView

struct LocationPickerView: View {
    @Binding var pickedLocation: PocketLocation?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var searchCompleter = LocationSearchCompleter()

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 41.9028, longitude: 12.4964),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )

    // Always tracks the exact center of the visible map
    @State private var mapCenter: CLLocationCoordinate2D = CLLocationCoordinate2D(
        latitude: 41.9028, longitude: 12.4964
    )

    // Reverse geocoded name for current center
    @State private var centerName: String = ""
    @State private var isGeocoding: Bool = false
    @State private var geocodeTask: DispatchWorkItem? = nil

    // Search
    @State private var searchText: String = ""
    @State private var showSuggestions: Bool = false
    @State private var isSearchFocused: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {

                // MARK: Map
                Map(position: $cameraPosition, interactionModes: .all) {
                    // No annotation here — we use the fixed overlay pin instead
                }
                .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .all))
                .ignoresSafeArea()
                .onMapCameraChange { context in
                    mapCenter = context.region.center
                    scheduleReverseGeocode(for: context.region.center)
                }

                // MARK: Fixed center pin (always in exact middle)
                VStack(spacing: 0) {
                    Spacer()

                    ZStack(alignment: .bottom) {
                        // Pin shadow on map
                        Ellipse()
                            .fill(Color.black.opacity(0.18))
                            .frame(width: 20, height: 6)
                            .blur(radius: 3)
                            .offset(y: 2)

                        VStack(spacing: 0) {
                            // Pin head
                            ZStack {
                                Circle()
                                    .fill(Color.primary)
                                    .frame(width: 38, height: 38)
                                    .shadow(color: .black.opacity(0.3), radius: 6, y: 3)
                                Image(systemName: "mappin")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            // Pin tail
                            Triangle()
                                .fill(Color.primary)
                                .frame(width: 14, height: 9)
                        }
                    }

                    Spacer()
                }
                .allowsHitTesting(false) // don't block map gestures

                // MARK: Top search overlay
                VStack(spacing: 0) {
                    VStack(spacing: 6) {
                        // Search bar
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)
                                .frame(width: 16)

                            TextField("Search for a place…", text: $searchText)
                                .autocorrectionDisabled()
                                .onSubmit {
                                    performSearch(query: searchText)
                                    showSuggestions = false
                                }
                                .onChange(of: searchText) { _, new in
                                    searchCompleter.queryFragment = new
                                    showSuggestions = !new.isEmpty
                                }

                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                    showSuggestions = false
                                    searchCompleter.queryFragment = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                        .shadow(color: .black.opacity(0.10), radius: 8, y: 3)

                        // Suggestions dropdown
                        if showSuggestions && !searchCompleter.results.isEmpty {
                            VStack(spacing: 0) {
                                ForEach(Array(searchCompleter.results.enumerated()), id: \.offset) { idx, result in
                                    Button {
                                        performSearch(completion: result)
                                        searchText = result.title
                                        showSuggestions = false
                                    } label: {
                                        HStack(spacing: 12) {
                                            Image(systemName: "mappin")
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                                .frame(width: 18)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(result.title)
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                    .foregroundStyle(.primary)
                                                    .lineLimit(1)
                                                if !result.subtitle.isEmpty {
                                                    Text(result.subtitle)
                                                        .font(.caption)
                                                        .foregroundStyle(.secondary)
                                                        .lineLimit(1)
                                                }
                                            }
                                            Spacer()
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                    }
                                    .buttonStyle(.plain)

                                    if idx < searchCompleter.results.count - 1 {
                                        Divider().padding(.leading, 44)
                                    }
                                }
                            }
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                            .shadow(color: .black.opacity(0.10), radius: 8, y: 3)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)

                    Spacer()
                }

                // MARK: Bottom confirm panel
                VStack {
                    Spacer()

                    VStack(spacing: 12) {
                        // Current location name pill
                        HStack(spacing: 10) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.primary)

                            VStack(alignment: .leading, spacing: 2) {
                                if isGeocoding {
                                    Text("Locating…")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text(centerName.isEmpty ? "Move map to pick location" : centerName)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                }
                                Text(String(format: "%.5f,  %.5f", mapCenter.latitude, mapCenter.longitude))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                        .padding(14)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 2)

                        // Confirm button
                        Button {
                            pickedLocation = PocketLocation(
                                latitude: mapCenter.latitude,
                                longitude: mapCenter.longitude,
                                name: centerName.isEmpty ? "Pinned Location" : centerName
                            )
                            dismiss()
                        } label: {
                            Text("Confirm Location")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.primary, in: RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(centerName.isEmpty && isGeocoding)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle("Pick Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .onAppear { loadExistingLocation() }
    }

    // MARK: - Helpers

    private func loadExistingLocation() {
        guard let loc = pickedLocation else { return }
        mapCenter = loc.coordinate
        centerName = loc.name
        cameraPosition = .region(MKCoordinateRegion(
            center: loc.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    private func scheduleReverseGeocode(for coord: CLLocationCoordinate2D) {
        // Debounce — only geocode after user stops moving map for 0.6s
        geocodeTask?.cancel()
        isGeocoding = true
        centerName = ""

        let task = DispatchWorkItem {
            reverseGeocode(coord)
        }
        geocodeTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: task)
    }

    private func reverseGeocode(_ coord: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let loc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        geocoder.reverseGeocodeLocation(loc) { placemarks, _ in
            DispatchQueue.main.async {
                isGeocoding = false
                centerName = placemarks?.first?.name
                    ?? placemarks?.first?.locality
                    ?? "Pinned Location"
            }
        }
    }

    private func performSearch(query: String) {
        let req = MKLocalSearch.Request()
        req.naturalLanguageQuery = query
        MKLocalSearch(request: req).start { response, _ in
            guard let item = response?.mapItems.first else { return }
            moveMap(to: item.placemark.coordinate, name: item.name ?? query)
        }
    }

    private func performSearch(completion: MKLocalSearchCompletion) {
        let req = MKLocalSearch.Request(completion: completion)
        MKLocalSearch(request: req).start { response, _ in
            guard let item = response?.mapItems.first else { return }
            moveMap(to: item.placemark.coordinate, name: item.name ?? completion.title)
        }
    }

    private func moveMap(to coord: CLLocationCoordinate2D, name: String) {
        DispatchQueue.main.async {
            mapCenter = coord
            centerName = name
            isGeocoding = false
            cameraPosition = .region(MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
    }
}

// MARK: - Triangle

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
