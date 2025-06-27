//
//  GymRestTimerApp.swift
//  GymRestTimer
//
//  Created by Aaron Lin on 6/27/25.
//

// GymRestTimerApp.swift

import SwiftUI

@main
struct GymRestTimerApp: App {
    // This creates one instance of our ViewModel and keeps it alive for the entire app lifecycle.
    @StateObject private var workoutViewModel = WorkoutViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                // We pass the ViewModel into the view's environment so all child views can access it.
                .environmentObject(workoutViewModel)
                .onAppear {
                    // Request permission for notifications as soon as the app appears.
                    NotificationManager.shared.requestAuthorization()
                }
        }
    }
}
