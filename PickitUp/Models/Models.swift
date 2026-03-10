import Foundation
import SwiftUI
import Combine

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

    // Sunday = 1 ... Saturday = 7
    var calendarWeekday: Int {
        switch self {
        case .sun: return 1
        case .mon: return 2
        case .tue: return 3
        case .wed: return 4
        case .thu: return 5
        case .fri: return 6
        case .sat: return 7
        }
    }
}

// MARK: - PocketItem

struct PocketItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var sfSymbol: String
}

// MARK: - Pocket

struct Pocket: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var sfSymbol: String
    var days: [Weekday]
    var reminderTime: Date
    var items: [PocketItem]

    private static let reminderFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()

    var reminderTimeString: String {
        Self.reminderFormatter.string(from: reminderTime)
    }

    var daysSummary: String {
        let orderedDays = Weekday.allCases.filter { days.contains($0) }

        if orderedDays.isEmpty { return "No days set" }
        if orderedDays.count == 7 { return "Every day" }

        let weekdays: [Weekday] = [.mon, .tue, .wed, .thu, .fri]
        let weekend: [Weekday] = [.sat, .sun]

        if Set(orderedDays) == Set(weekdays) { return "Weekdays" }
        if Set(orderedDays) == Set(weekend) { return "Weekends" }

        return orderedDays.map(\.rawValue).joined(separator: ", ")
    }

    static func defaultTime() -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 17
        components.minute = 30
        return Calendar.current.date(from: components) ?? Date()
    }
}

// MARK: - Persistence

private enum StorageKey {
    static let pockets = "pickitup.pockets.v2"
    static let trayItems = "pickitup.trayItems.v2"
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

@MainActor
final class AppStore: ObservableObject {

    @Published var pockets: [Pocket] {
        didSet { save(pockets, key: StorageKey.pockets) }
    }

    @Published var trayItems: [PocketItem] {
        didSet { save(trayItems, key: StorageKey.trayItems) }
    }

    init() {
        self.pockets = load([Pocket].self, key: StorageKey.pockets) ?? []
        self.trayItems = load([PocketItem].self, key: StorageKey.trayItems) ?? []

        Task {
            let status = await NotificationManager.shared.getAuthorizationStatus()
            if status == .authorized || status == .provisional || status == .ephemeral {
                await NotificationManager.shared.rescheduleAll(pockets: self.pockets)
            }
        }
    }

    // MARK: - Pocket CRUD

    func addPocket(_ pocket: Pocket) {
        pockets.append(pocket)

        Task {
            let status = await NotificationManager.shared.getAuthorizationStatus()

            if status == .notDetermined {
                let granted = await NotificationManager.shared.requestPermission()
                if granted {
                    await NotificationManager.shared.scheduleNotifications(for: pocket)
                }
            } else if status == .authorized || status == .provisional || status == .ephemeral {
                await NotificationManager.shared.scheduleNotifications(for: pocket)
            }
        }
    }

    func updatePocket(_ pocket: Pocket) {
        guard let idx = pockets.firstIndex(where: { $0.id == pocket.id }) else { return }

        pockets[idx] = pocket

        Task {
            let status = await NotificationManager.shared.getAuthorizationStatus()
            if status == .authorized || status == .provisional || status == .ephemeral {
                await NotificationManager.shared.scheduleNotifications(for: pocket)
            }
        }
    }

    func deletePocket(id: UUID) {
        guard let pocket = pockets.first(where: { $0.id == id }) else {
            pockets.removeAll { $0.id == id }
            return
        }

        NotificationManager.shared.removeNotifications(for: pocket)
        pockets.removeAll { $0.id == id }
    }

    // MARK: - Tray Item CRUD

    func addTrayItem(_ item: PocketItem) {
        trayItems.append(item)
    }

    func updateTrayItem(_ item: PocketItem) {
        if let idx = trayItems.firstIndex(where: { $0.id == item.id }) {
            trayItems[idx] = item
        }

        for pocketIndex in pockets.indices {
            if let itemIndex = pockets[pocketIndex].items.firstIndex(where: { $0.id == item.id }) {
                pockets[pocketIndex].items[itemIndex] = item
            }
        }
    }

    func deleteTrayItem(id: UUID) {
        trayItems.removeAll { $0.id == id }

        for pocketIndex in pockets.indices {
            pockets[pocketIndex].items.removeAll { $0.id == id }
        }
    }

    // MARK: - Pocket ↔ Item

    func addItemToPocket(item: PocketItem, pocketId: UUID) {
        guard let idx = pockets.firstIndex(where: { $0.id == pocketId }) else { return }

        if !pockets[idx].items.contains(where: { $0.id == item.id }) {
            pockets[idx].items.append(item)
        }
    }

    func removeItemFromPocket(itemId: UUID, pocketId: UUID) {
        guard let idx = pockets.firstIndex(where: { $0.id == pocketId }) else { return }
        pockets[idx].items.removeAll { $0.id == itemId }
    }
}
