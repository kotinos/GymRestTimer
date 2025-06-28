# GymRestTimer Component Interactions

## Overview

This document details how the different components of the GymRestTimer app interact with each other, including data flow, method calls, and state synchronization.

## Component Interaction Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              User Interactions                              │
└─────────────────┬───────────────────────────────┬─────────────────────────────┘
                  │                               │
                  ▼                               ▼
┌─────────────────────────────┐         ┌─────────────────────────────┐
│        ContentView          │         │        AlarmView            │
│                             │         │                             │
│ • Timer Display             │         │ • "REST OVER!" Message     │
│ • Start/Stop Button         │         │ • Dismiss Button           │
│ • Duration Stepper          │         │                             │
│ • End Workout Button        │         │                             │
└─────────────┬───────────────┘         └─────────────┬───────────────┘
              │                                       │
              │ @EnvironmentObject                    │ @EnvironmentObject
              │                                       │
              ▼                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          WorkoutViewModel                                   │
│                                                                             │
│ @Published Properties:                                                      │
│ • isResting: Bool                                                          │
│ • isAlarmActive: Bool                                                      │
│ • timeString: String                                                       │
│ • progress: Double                                                         │
│ • restDuration: TimeInterval                                               │
│                                                                             │
│ Private Properties:                                                         │
│ • timer: AnyCancellable?                                                   │
│ • timerEndDate: Date?                                                      │
│ • backgroundTaskID: UIBackgroundTaskIdentifier                             │
└─────────────┬───────────────────────────────────────┬─────────────────────┘
              │                                       │
              │ scheduleRestNotification()             │ Timer.publish()
              │ cancelNotifications()                  │ .sink()
              ▼                                       ▼
┌─────────────────────────────┐         ┌─────────────────────────────┐
│    NotificationManager      │         │      Combine Framework      │
│                             │         │                             │
│ • Schedule notifications    │         │ • Timer publishers          │
│ • Cancel notifications      │         │ • Reactive updates          │
│ • Request permissions       │         │ • Automatic cancellation    │
└─────────────────────────────┘         └─────────────────────────────┘
              │                                       │
              │ UNUserNotificationCenter               │ Main RunLoop
              ▼                                       ▼
┌─────────────────────────────┐         ┌─────────────────────────────┐
│      iOS Notifications      │         │        UI Updates           │
│                             │         │                             │
│ • Background alerts         │         │ • Automatic view refresh    │
│ • Critical sounds           │         │ • Progress animation        │
│ • Lock screen display       │         │ • State-driven UI changes   │
└─────────────────────────────┘         └─────────────────────────────┘
```

## Detailed Interaction Flows

### 1. Timer Start Flow

```
User taps "START REST" button
         │
         ▼
ContentView.actionButton action
         │
         ▼
viewModel.isResting.toggle() // true
         │
         ▼
WorkoutViewModel.isResting didSet observer
         │
         ▼
WorkoutViewModel.startRestTimer()
         │
         ├─── Set timerEndDate = Date() + restDuration
         │
         ├─── NotificationManager.shared.scheduleRestNotification(duration: restDuration)
         │    │
         │    ├─── cancelNotifications() // Clear previous
         │    ├─── Create UNMutableNotificationContent
         │    ├─── Set critical sound and time-sensitive level
         │    └─── Schedule with UNUserNotificationCenter
         │
         └─── Start Combine Timer
              │
              ├─── Timer.publish(every: 1, on: .main, in: .common)
              ├─── .autoconnect()
              └─── .sink { updateUI() }
                   │
                   ├─── Calculate remaining = timerEndDate.timeIntervalSinceNow
                   ├─── Update timeString = formatTime(remaining)
                   ├─── Update progress = remaining / restDuration
                   └─── Check if remaining <= 0 → trigger alarm
```

### 2. Timer Completion Flow

```
Timer reaches zero (remaining <= 0)
         │
         ▼
WorkoutViewModel.updateUI() detects expiration
         │
         ├─── Set timeString = "00:00"
         ├─── Set progress = 0.0
         ├─── Set isAlarmActive = true
         └─── Cancel timer
         │
         ▼
SwiftUI reactive update triggered by @Published isAlarmActive
         │
         ▼
ContentView.body re-evaluates
         │
         ├─── Main content gets blur(radius: 20)
         └─── AlarmView appears in ZStack
         │
         ▼
iOS System Notification fires (if app in background)
         │
         ├─── Critical sound plays
         ├─── Lock screen notification appears
         └─── Badge/alert shown
```

### 3. Alarm Dismissal Flow

```
User taps "Dismiss & Start Next Set" in AlarmView
         │
         ▼
AlarmView button action
         │
         ▼
viewModel.stopAlarmAndReset()
         │
         ├─── Set isAlarmActive = false
         └─── Set isResting = false
         │
         ▼
WorkoutViewModel.isResting didSet observer (false)
         │
         ▼
WorkoutViewModel.stopRestTimer()
         │
         ├─── Cancel timer?.cancel()
         ├─── Set timerEndDate = nil
         ├─── Reset progress = 1.0
         ├─── Reset timeString = formatTime(restDuration)
         └─── NotificationManager.shared.cancelNotifications()
         │
         ▼
SwiftUI reactive updates
         │
         ├─── AlarmView disappears (isAlarmActive = false)
         ├─── Main content blur removed
         ├─── Button text changes to "START REST"
         └─── Button color changes to green
```

### 4. App Lifecycle Interaction Flow

```
App moves to background
         │
         ▼
UIApplication.willResignActiveNotification
         │
         ▼
ContentView.onReceive() → viewModel.handleAppWillResignActive()
         │
         ├─── Record resignActiveTime = Date()
         ├─── Set isProcessingBackgroundTransition = true
         └─── Start background task
         │
         ▼
UIApplication.didEnterBackgroundNotification
         │
         ▼
ContentView.onReceive() → viewModel.handleAppDidEnterBackground()
         │
         └─── Schedule background task cleanup
         │
         ▼
Screen Lock Detection (if applicable)
         │
         ▼
UIApplication.protectedDataWillBecomeUnavailableNotification
         │
         ▼
WorkoutViewModel.handleScreenLock()
         │
         ├─── Set wasScreenLocked = true
         └─── If isAlarmActive → stopAlarmAndReset()
         │
         ▼
App returns to foreground
         │
         ▼
UIApplication.didBecomeActiveNotification
         │
         ▼
ContentView.onReceive() → viewModel.handleAppMovedToForeground()
         │
         ├─── Check if timer expired while backgrounded
         ├─── If expired → set isAlarmActive = true
         ├─── Else → updateUI() to sync current state
         └─── End background task
```

### 5. Settings Change Flow

```
User adjusts duration stepper
         │
         ▼
ContentView.settings Stepper binding
         │
         ▼
$viewModel.restDuration two-way binding
         │
         ▼
WorkoutViewModel.restDuration didSet observer
         │
         ▼
If !isResting (timer not active):
         │
         ├─── Update timeString = formatTime(restDuration)
         └─── Reset progress = 1.0
         │
         ▼
SwiftUI reactive updates
         │
         ├─── Timer display shows new duration
         └─── Stepper shows new value
```

## State Synchronization Patterns

### 1. Reactive UI Updates
- **Pattern**: `@Published` properties automatically trigger SwiftUI view updates
- **Components**: All UI elements bound to WorkoutViewModel properties
- **Benefit**: Eliminates manual UI synchronization code

### 2. Observer Pattern for App Lifecycle
- **Pattern**: NotificationCenter observers for UIApplication events
- **Components**: ContentView registers observers, WorkoutViewModel handles events
- **Benefit**: Automatic background/foreground state management

### 3. Singleton for Global Services
- **Pattern**: NotificationManager.shared singleton instance
- **Components**: WorkoutViewModel calls notification methods
- **Benefit**: Centralized notification management across app

### 4. Dependency Injection via Environment
- **Pattern**: `@EnvironmentObject` for ViewModel sharing
- **Components**: GymRestTimerApp injects, ContentView and AlarmView consume
- **Benefit**: Loose coupling between views and business logic

## Error Handling and Edge Cases

### 1. Background Task Expiration
```
Background task about to expire
         │
         ▼
UIApplication.shared.beginBackgroundTask() completion handler
         │
         ▼
WorkoutViewModel.endBackgroundTask()
         │
         └─── Clean up background task ID
```

### 2. Notification Permission Denied
```
User denies notification permission
         │
         ▼
NotificationManager.requestAuthorization() completion
         │
         ├─── granted = false
         └─── Print error message
         │
         ▼
App continues to function
         │
         └─── Timer works in foreground, no background alerts
```

### 3. Timer State Recovery
```
App killed and relaunched during active timer
         │
         ▼
WorkoutViewModel.init()
         │
         ├─── timerEndDate = nil (lost state)
         ├─── isResting = false
         └─── Timer resets to default duration
         │
         ▼
User must manually restart timer
```

## Performance Considerations

### 1. Timer Efficiency
- **Frequency**: 1-second updates only when timer is active
- **Cancellation**: Automatic cleanup when timer stops
- **Memory**: Weak references in Combine sinks prevent retain cycles

### 2. Background Processing
- **Limited Time**: Background tasks have ~30 seconds execution time
- **State Preservation**: Uses `timerEndDate` for accurate time calculation
- **Resource Cleanup**: Proper background task termination

### 3. UI Responsiveness
- **Main Thread**: All UI updates on main queue via `@MainActor`
- **Reactive Updates**: Minimal view re-computation with targeted `@Published` properties
- **Animation**: Smooth progress animation with `.linear` timing
