//
//  WorkoutViewModel.swift
//  GymRestTimer
//
//  Created by Aaron Lin on 6/27/25.
//


// WorkoutViewModel.swift

import SwiftUI
import Combine
import UIKit

@MainActor // Ensures UI-related updates happen on the main thread
class WorkoutViewModel: ObservableObject {

    // MARK: - Published Properties (The View listens to these)
    @Published var isResting = false {
        didSet {
            if isResting {
                startRestTimer()
            } else {
                stopRestTimer()
            }
        }
    }
    @Published var isAlarmActive = false
    @Published var timeString: String = "01:30"
    @Published var progress: Double = 1.0
    @Published var restDuration: TimeInterval = 90 {
        didSet {
            if !isResting {
                self.timeString = formatTime(restDuration)
                self.progress = 1.0
            }
        }
    }

    // MARK: - Private Properties
    private var timer: AnyCancellable?
    private var timerEndDate: Date?
    private var isScreenOff = false
    private var minimizeTimer: Timer?

    init() {
        // Set initial time string when the app starts
        self.timeString = formatTime(restDuration)
    }
    
    deinit {
        minimizeTimer?.invalidate()
        minimizeTimer = nil
    }

    // MARK: - Timer Control
    private func startRestTimer() {
        print("Starting rest timer for \(restDuration) seconds.")
        timerEndDate = Date().addingTimeInterval(restDuration)

        // Schedule the background notification
        NotificationManager.shared.scheduleRestNotification(duration: restDuration)

        // Start a foreground timer to update the UI every second
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            self?.updateUI()
        }
    }

    private func stopRestTimer() {
        print("Stopping rest timer.")
        timer?.cancel()
        timer = nil
        timerEndDate = nil
        progress = 1.0
        timeString = formatTime(restDuration)
        
        // Always cancel notifications when the user stops it manually
        NotificationManager.shared.cancelNotifications()
    }
    
    func stopAlarmAndReset() {
        isAlarmActive = false
        isResting = false // This will trigger the stopRestTimer() logic via the didSet observer
    }
    
    func endWorkout() {
        print("Ending workout session.")
        isAlarmActive = false
        isResting = false
        timer?.cancel()
        timer = nil
        timerEndDate = nil
        progress = 1.0
        timeString = formatTime(restDuration)
        NotificationManager.shared.cancelNotifications()
    }

    // MARK: - UI Update Logic
    private func updateUI() {
        guard let endDate = timerEndDate else {
            stopRestTimer()
            return
        }

        let remaining = endDate.timeIntervalSinceNow
        if remaining > 0 {
            self.timeString = formatTime(remaining)
            self.progress = remaining / restDuration
        } else {
            // Timer finished!
            self.timeString = formatTime(0)
            self.progress = 0
            self.isAlarmActive = true
            timer?.cancel() // Stop the UI timer
        }
    }

    // MARK: - App Lifecycle Handling
    func handleAppMovedToBackground() {
        print("App moved to background.")
        
        minimizeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] timer in
            // Timer fired - assume power button press (screen lock)
            print("Timer expired - likely power button press (screen lock)")
            self?.handleScreenOff()
            self?.minimizeTimer = nil
        }
        
        print("Timer is running via scheduled notification.")
        // The foreground timer will pause, which is fine. The scheduled notification is our guarantee.
        // We save the end date so we can sync up when the app returns.
    }

    func handleAppMovedToForeground() {
        print("App moved to foreground.")
        
        if let timer = minimizeTimer {
            timer.invalidate()
            minimizeTimer = nil
            print("Cleaned up minimize timer on foreground.")
        }
        
        if let endDate = timerEndDate {
            // If the timer was running, check its status
            if Date() >= endDate {
                // If we've passed the end date, show the alarm immediately
                updateUI()
            } else {
                // Otherwise, just resume the UI updates
                updateUI()
            }
        }
    }
    
    func handleAppDidEnterBackground() {
        print("App did enter background.")
        
        if let timer = minimizeTimer {
            timer.invalidate()
            minimizeTimer = nil
            print("Intentional app minimize detected.")
            handleAppMinimized()
        }
    }
    
    func handleScreenOff() {
        print("Screen turned off (power button pressed).")
        isScreenOff = true
        
        if isAlarmActive {
            print("Auto-dismissing alarm due to screen off.")
            stopAlarmAndReset()
        }
    }
    
    func handleScreenOn() {
        print("Screen turned on.")
        isScreenOff = false
    }
    
    func handleAppMinimized() {
        print("App minimized to home screen.")
        
        if isAlarmActive {
            print("Auto-dismissing alarm due to app minimize.")
            stopAlarmAndReset()
        }
        else if !isResting {
            print("Auto-starting rest timer due to app minimize.")
            isResting = true
        }
    }
    
    // MARK: - Helper
    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
