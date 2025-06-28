//
//  NotificationManager.swift
//  GymRestTimer
//
//  Created by Aaron Lin on 6/27/25.
//


// NotificationManager.swift

import UserNotifications

class NotificationManager {
    static let shared = NotificationManager() // Singleton instance
    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    func scheduleRestNotification(duration: TimeInterval) {
        // Always clear previous notifications before scheduling a new one
        cancelNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "Rest Over!"
        content.subtitle = "Time for your next set."
        content.sound = .defaultCriticalSound(withAudioVolume: 1.0) // This ensures the sound plays even on silent.
        content.interruptionLevel = .timeSensitive // A key setting for this type of app.

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: duration, repeats: false)
        let request = UNNotificationRequest(identifier: "GYM_REST_TIMER", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Successfully scheduled notification.")
            }
        }
    }

    func cancelNotifications() {
        print("Cancelling all scheduled notifications.")
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
