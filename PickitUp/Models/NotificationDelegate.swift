//
//  NotificationDelegate.swift
//  PickitUp
//
//  Created by Burak Demirhan on 10/03/26.
//
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationDelegate()

    static var sharedPocketID: String?

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {

        let userInfo = response.notification.request.content.userInfo

        if let pocketID = userInfo["pocketID"] as? String {
            NotificationDelegate.sharedPocketID = pocketID
        }
    }
}
