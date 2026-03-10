//
//  NotificationManager.swift
//  PickitUp
//
//  Created by Burak Demirhan on 09/03/26.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    // MARK: - Permission

    func requestPermission() async -> Bool {
        do {
            let center = UNUserNotificationCenter.current()
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Notification permission error:", error.localizedDescription)
            return false
        }
    }

    func getAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Pocket Scheduling

    func scheduleNotifications(for pocket: Pocket) async {
        let center = UNUserNotificationCenter.current()

        // Önce o pocket'a ait eski bildirimleri sil
        removeNotifications(for: pocket)

        guard !pocket.days.isEmpty else { return }

        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: pocket.reminderTime)
        guard let hour = timeComponents.hour, let minute = timeComponents.minute else { return }

        for day in pocket.days {
            var components = DateComponents()
            components.weekday = day.calendarWeekday
            components.hour = hour
            components.minute = minute

            let content = UNMutableNotificationContent()
            content.title = "Don’t forget your \(pocket.name)"
            content.body = pocket.items.isEmpty
                ? "Check your pocket before leaving."
                : "Check your essentials before leaving."
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(
                identifier: identifier(for: pocket, day: day),
                content: content,
                trigger: trigger
            )

            do {
                try await center.add(request)
            } catch {
                print("Failed to schedule notification for \(pocket.name) - \(day.rawValue): \(error.localizedDescription)")
            }
        }
    }

    func removeNotifications(for pocket: Pocket) {
        let identifiers = Weekday.allCases.map { identifier(for: pocket, day: $0) }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func rescheduleAll(pockets: [Pocket]) async {
        let center = UNUserNotificationCenter.current()

        // Sadece app'in pocket bazlı bildirimlerini temizle
        let pending = await center.pendingNotificationRequests()
        let pocketNotificationIDs = pending
            .map(\.identifier)
            .filter { $0.hasPrefix("pocket-") }

        center.removePendingNotificationRequests(withIdentifiers: pocketNotificationIDs)

        for pocket in pockets {
            await scheduleNotifications(for: pocket)
        }
    }

    // MARK: - Debug / Testing

    func scheduleTestNotification(after seconds: TimeInterval = 5) async {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "PickitUP Test"
        content.body = "This is a test notification."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(seconds, 1), repeats: false)

        let request = UNNotificationRequest(
            identifier: "pickitup.test.notification",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("Failed to schedule test notification: \(error.localizedDescription)")
        }
    }

    // MARK: - Helpers

    private func identifier(for pocket: Pocket, day: Weekday) -> String {
        "pocket-\(pocket.id.uuidString)-\(day.rawValue.lowercased())"
    }
}
