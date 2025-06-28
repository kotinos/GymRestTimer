//
//  WorkoutViewModel.swift
//  GymRestTimer
//
//  Created by Aaron Lin on 6/27/25.
//

import SwiftUI
import Combine
import UIKit

@MainActor
class WorkoutViewModel: ObservableObject {
    // MARK: - Published Properties
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
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    private var resignActiveTime: Date?
    private var wasScreenLocked = false
    private var isProcessingBackgroundTransition = false
    
    init() {
        self.timeString = formatTime(restDuration)
        setupNotificationObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Notification Observers
    private func setupNotificationObservers() {
        // Listen for screen lock/unlock events
        NotificationCenter.default.addObserver(
            forName: UIApplication.protectedDataWillBecomeUnavailableNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleScreenLock()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.protectedDataDidBecomeAvailableNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleScreenUnlock()
        }
    }
    
    // MARK: - Timer Control
    private func startRestTimer() {
        print("Starting rest timer for $restDuration) seconds.")
        timerEndDate = Date().addingTimeInterval(restDuration)
        
        NotificationManager.shared.scheduleRestNotification(duration: restDuration)
        
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
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
        NotificationManager.shared.cancelNotifications()
    }
    
    func stopAlarmAndReset() {
        isAlarmActive = false
        isResting = false
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
            self.timeString = formatTime(0)
            self.progress = 0
            self.isAlarmActive = true
            timer?.cancel()
        }
    }
    
    // MARK: - App Lifecycle Handling
    func handleAppWillResignActive() {
        print("App will resign active.")
        resignActiveTime = Date()
        isProcessingBackgroundTransition = true
        wasScreenLocked = false
        
        // Start a background task to ensure we have time to process
        if backgroundTaskID == .invalid {
            backgroundTaskID = UIApplication.shared.beginBackgroundTask { [weak self] in
                self?.endBackgroundTask()
            }
        }
    }
    
    func handleSceneDidEnterBackground() {
        print("Scene did enter background.")
        
        // Only process if we haven't detected a screen lock
        if !wasScreenLocked && isProcessingBackgroundTransition {
            // Small delay to ensure screen lock notification would have been received
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let self = self else { return }
                
                if !self.wasScreenLocked {
                    print("Confirmed app minimize (no screen lock detected).")
                    self.handleAppMinimized()
                }
                
                self.isProcessingBackgroundTransition = false
            }
        }
    }
    
    func handleAppDidEnterBackground() {
        print("App did enter background.")
        
        // Clean up background task after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    func handleAppMovedToForeground() {
        print("App moved to foreground.")
        wasScreenLocked = false
        isProcessingBackgroundTransition = false
        
        if let endDate = timerEndDate {
            if Date() >= endDate && !isAlarmActive {
                // Timer expired while in background
                self.isAlarmActive = true
                self.timeString = formatTime(0)
                self.progress = 0
                timer?.cancel()
            } else {
                // Update UI to current state
                updateUI()
            }
        }
        
        endBackgroundTask()
    }
    
    // MARK: - Screen Lock Handling
    private func handleScreenLock() {
        print("Screen locked (power button pressed).")
        wasScreenLocked = true
        
        if isAlarmActive {
            print("Auto-dismissing alarm due to screen lock.")
            stopAlarmAndReset()
        }
    }
    
    private func handleScreenUnlock() {
        print("Screen unlocked.")
        // Don't reset wasScreenLocked here as we might still be processing the transition
    }
    
    // MARK: - App Minimize Handling
    private func handleAppMinimized() {
        print("App minimized to home screen.")
        
        if isAlarmActive {
            print("Auto-dismissing alarm due to app minimize.")
            stopAlarmAndReset()
        } else if !isResting {
            print("Auto-starting rest timer due to app minimize.")
            isResting = true
        }
    }
    
    // MARK: - Background Task Management
    private func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }
    
    // MARK: - Helper
    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
