//
//  NotificationManager.swift
//  PickitUp
//
//
//  NotificationManager.swift
//  PickitUp
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
            print("Notification permission error: \(error.localizedDescription)")
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
        
        removeNotifications(for: pocket)
        
        guard !pocket.days.isEmpty else { return }
        
        let timeComponents = Calendar.current.dateComponents(
            [.hour, .minute],
            from: pocket.reminderTime
        )
        
        guard let hour = timeComponents.hour,
              let minute = timeComponents.minute else { return }
        
        for day in pocket.days {
            var components = DateComponents()
            components.weekday = day.calendarWeekday
            components.hour = hour
            components.minute = minute
            
            let content = UNMutableNotificationContent()
            content.title = "Ready to leave?"
            content.body = notificationBody(for: pocket)
            content.sound = .default
            content.userInfo = [
                "pocketID": pocket.id.uuidString
            ]
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: true
            )
            
            let request = UNNotificationRequest(
                identifier: identifier(for: pocket, day: day),
                content: content,
                trigger: trigger
            )
            
            do {
                try await center.add(request)
            } catch {
                print("Failed to schedule notification for \(pocket.name): \(error.localizedDescription)")
            }
        }
    }
    
    func removeNotifications(for pocket: Pocket) {
        let identifiers = Weekday.allCases.map {
            identifier(for: pocket, day: $0)
        }
        
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func rescheduleAll(pockets: [Pocket]) async {
        let center = UNUserNotificationCenter.current()
        
        let pending = await center.pendingNotificationRequests()
        let pocketNotificationIDs = pending
            .map(\.identifier)
            .filter { $0.hasPrefix("pocket-") }
        
        center.removePendingNotificationRequests(withIdentifiers: pocketNotificationIDs)
        
        for pocket in pockets {
            await self.scheduleNotifications(for: pocket)
        }
    }
    
    // MARK: - Notification Text
    
    private func notificationBody(for pocket: Pocket) -> String {
        if pocket.items.isEmpty {
            return "Your \(pocket.name) pocket has no items yet. Add essentials before leaving."
        }
        
        let count = pocket.items.count
        
        if count == 1 {
            return "Check your \(pocket.name) pocket. You have 1 item waiting."
        }
        
        return "Check your \(pocket.name) pocket. You have \(count) items waiting."
    }
    
    // MARK: - Helpers
    
    private func identifier(for pocket: Pocket, day: Weekday) -> String {
        "pocket-\(pocket.id.uuidString)-\(day.rawValue.lowercased())"
    }
}
