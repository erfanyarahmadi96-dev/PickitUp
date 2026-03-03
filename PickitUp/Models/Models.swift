import Foundation
import CoreLocation
import SwiftUI
internal import Combine
import MapKit

// MARK: - Weekday

enum Weekday: String, CaseIterable, Codable, Identifiable {
    case mon = "Mon"
    case tue = "Tue"
    case wed = "Wed"
    case thu = "Thu"
    case fri = "Fri"
    case sat = "Sat"
    case sun = "Sun"

    var id: String { rawValue }

    var full: String {
        switch self {
        case .mon: return "Monday"
        case .tue: return "Tuesday"
        case .wed: return "Wednesday"
        case .thu: return "Thursday"
        case .fri: return "Friday"
        case .sat: return "Saturday"
        case .sun: return "Sunday"
        }
    }
}

// MARK: - PocketItem

struct PocketItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var sfSymbol: String
}

// MARK: - PocketLocation

struct PocketLocation: Codable, Equatable {
    var latitude: Double
    var longitude: Double
    var name: String

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Pocket

struct Pocket: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var sfSymbol: String
    var days: [Weekday]
    var reminderTime: Date
    var items: [PocketItem]
    var location: PocketLocation

    var reminderTimeString: String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: reminderTime)
    }

    var daysSummary: String {
        if days.isEmpty { return "No days set" }
        if days.count == 7 { return "Every day" }
        let weekdays: [Weekday] = [.mon, .tue, .wed, .thu, .fri]
        let weekend: [Weekday]  = [.sat, .sun]
        if Set(days) == Set(weekdays) { return "Weekdays" }
        if Set(days) == Set(weekend)  { return "Weekends" }
        return days.map(\.rawValue).joined(separator: ", ")
    }

    static func defaultTime() -> Date {
        var c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        c.hour   = 17
        c.minute = 30
        return Calendar.current.date(from: c) ?? Date()
    }
}

// MARK: - Persistence

private enum StorageKey {
    static let pockets   = "pickitup.pockets"
    static let trayItems = "pickitup.trayItems"
}

private func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
    guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
    return try? JSONDecoder().decode(T.self, from: data)
}

private func save<T: Encodable>(_ value: T, key: String) {
    guard let data = try? JSONEncoder().encode(value) else { return }
    UserDefaults.standard.set(data, forKey: key)
}

// MARK: - AppStore

class AppStore: ObservableObject {

    @Published var pockets: [Pocket] {
        didSet { save(pockets, key: StorageKey.pockets) }
    }

    @Published var trayItems: [PocketItem] {
        didSet { save(trayItems, key: StorageKey.trayItems) }
    }

    init() {
        // Load from storage — empty arrays if first launch
        self.pockets   = load([Pocket].self,     key: StorageKey.pockets)   ?? []
        self.trayItems = load([PocketItem].self, key: StorageKey.trayItems) ?? []
    }

    // MARK: - Pocket CRUD

    func addPocket(_ pocket: Pocket) {
        pockets.append(pocket)
    }

    func updatePocket(_ pocket: Pocket) {
        if let idx = pockets.firstIndex(where: { $0.id == pocket.id }) {
            pockets[idx] = pocket
        }
    }

    func deletePocket(id: UUID) {
        pockets.removeAll { $0.id == id }
    }

    // MARK: - Item CRUD

    func addTrayItem(_ item: PocketItem) {
        trayItems.append(item)
    }

    func updateTrayItem(_ item: PocketItem) {
        if let idx = trayItems.firstIndex(where: { $0.id == item.id }) {
            trayItems[idx] = item
        }
        // Keep in sync inside all pockets
        for pi in 0..<pockets.count {
            if let ii = pockets[pi].items.firstIndex(where: { $0.id == item.id }) {
                pockets[pi].items[ii] = item
            }
        }
    }

    func deleteTrayItem(id: UUID) {
        trayItems.removeAll { $0.id == id }
        // Also remove from every pocket
        for pi in 0..<pockets.count {
            pockets[pi].items.removeAll { $0.id == id }
        }
    }

    // MARK: - Pocket ↔ Item

    func addItemToPocket(item: PocketItem, pocketId: UUID) {
        if let idx = pockets.firstIndex(where: { $0.id == pocketId }) {
            if !pockets[idx].items.contains(where: { $0.id == item.id }) {
                pockets[idx].items.append(item)
            }
        }
    }

    func removeItemFromPocket(itemId: UUID, pocketId: UUID) {
        if let idx = pockets.firstIndex(where: { $0.id == pocketId }) {
            pockets[idx].items.removeAll { $0.id == itemId }
        }
    }
}
