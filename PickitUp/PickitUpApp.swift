//
//  PickitUpApp.swift
//  PickitUp
//
//  Created by Erfan Yarahmadi on 23/02/26.
//

import SwiftUI
import UserNotifications

@main
struct PickitUpApp: App {
    
    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
