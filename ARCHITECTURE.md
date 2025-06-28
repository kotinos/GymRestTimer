# GymRestTimer iOS App - Architecture Documentation

## Overview

GymRestTimer is a SwiftUI-based iOS application designed to help gym users manage rest periods between exercise sets. The app follows the **Model-View-ViewModel (MVVM)** architectural pattern with reactive programming using Combine framework.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        GymRestTimer App                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐    ┌──────────────────┐    ┌─────────────┐ │
│  │   ContentView   │───▶│ WorkoutViewModel │───▶│NotificationMgr│ │
│  │   (Main UI)     │    │ (Business Logic) │    │ (Background)│ │
│  │                 │    │                  │    │             │ │
│  │   AlarmView     │───▶│                  │    │             │ │
│  │ (Timer Complete)│    │                  │    │             │ │
│  └─────────────────┘    └──────────────────┘    └─────────────┘ │
│           │                       │                      │      │
│           │              ┌────────▼────────┐            │      │
│           │              │ Timer Publishers │            │      │
│           │              │ & Combine Sinks  │            │      │
│           │              └─────────────────┘            │      │
│           │                                             │      │
│  ┌────────▼────────┐                          ┌────────▼────┐  │
│  │ App Lifecycle   │                          │ iOS System  │  │
│  │ Notifications   │                          │Notifications │  │
│  └─────────────────┘                          └─────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Core Components

### 1. GymRestTimerApp (Entry Point)
- **File**: `GymRestTimerApp.swift`
- **Role**: Application entry point and dependency injection
- **Key Responsibilities**:
  - Creates and manages the `WorkoutViewModel` as a `@StateObject`
  - Injects the ViewModel into the SwiftUI environment
  - Requests notification permissions on app launch

### 2. WorkoutViewModel (Business Logic)
- **File**: `WorkoutViewModel.swift`
- **Role**: Central state manager implementing MVVM pattern
- **Key Responsibilities**:
  - Timer state management (`isResting`, `timeString`, `progress`)
  - App lifecycle handling (background/foreground transitions)
  - Screen lock detection and auto-dismiss logic
  - Background task management
  - Integration with NotificationManager

**Published Properties**:
```swift
@Published var isResting: Bool = false
@Published var isAlarmActive: Bool = false
@Published var timeString: String = "01:30"
@Published var progress: Double = 1.0
@Published var restDuration: TimeInterval = 90
```

### 3. ContentView (Main User Interface)
- **File**: `ContentView.swift`
- **Role**: Primary SwiftUI view with timer display and controls
- **Key Responsibilities**:
  - Circular progress timer display
  - Start/Stop rest timer controls
  - Duration settings (15-300 seconds)
  - App lifecycle notification handling
  - Conditional AlarmView presentation

### 4. AlarmView (Timer Completion Modal)
- **File**: `AlarmView.swift`
- **Role**: Modal overlay displayed when timer completes
- **Key Responsibilities**:
  - Full-screen alarm interface
  - "REST OVER!" notification display
  - Dismiss and reset functionality

### 5. NotificationManager (Background Alerts)
- **File**: `NotificationManager.swift`
- **Role**: Singleton service for background notification handling
- **Key Responsibilities**:
  - Local notification scheduling
  - Critical sound alerts (bypass silent mode)
  - Notification permission management
  - Notification cancellation

## Data Flow Architecture

### Timer Lifecycle Flow
```
User Taps "START REST"
         │
         ▼
WorkoutViewModel.isResting = true
         │
         ▼
startRestTimer() called
         │
         ├─── Set timerEndDate
         ├─── Schedule notification
         └─── Start Combine timer
         │
         ▼
Timer publishes every 1 second
         │
         ▼
updateUI() calculates remaining time
         │
         ├─── Update timeString
         ├─── Update progress (0.0-1.0)
         └─── Check if timer expired
         │
         ▼
Timer expires (remaining <= 0)
         │
         ├─── Set isAlarmActive = true
         ├─── Cancel timer
         └─── Show AlarmView
```

### App Lifecycle Flow
```
App Backgrounded
         │
         ▼
handleAppWillResignActive()
         │
         ├─── Record resignActiveTime
         ├─── Start background task
         └─── Set processing flag
         │
         ▼
Screen Lock Detection
         │
         ├─── wasScreenLocked = true
         └─── Auto-dismiss alarm if active
         │
         ▼
App Foregrounded
         │
         ├─── Check timer expiration
         ├─── Update UI state
         └─── End background task
```

## Key Design Patterns

### 1. MVVM (Model-View-ViewModel)
- **Model**: Timer state and duration settings
- **View**: SwiftUI views (ContentView, AlarmView)
- **ViewModel**: WorkoutViewModel with `@Published` properties

### 2. Reactive Programming
- Uses Combine framework for timer updates
- `@Published` properties trigger UI updates automatically
- Timer.publish() creates reactive timer stream

### 3. Singleton Pattern
- NotificationManager uses singleton for global access
- Ensures single notification scheduling instance

### 4. Observer Pattern
- App lifecycle notifications via NotificationCenter
- Screen lock/unlock detection
- Automatic UI updates via SwiftUI's reactive system

## State Management

### Timer States
1. **Idle**: `isResting = false`, timer not running
2. **Active**: `isResting = true`, timer counting down
3. **Alarm**: `isAlarmActive = true`, timer completed

### Background Handling
- Preserves timer state using `timerEndDate`
- Handles screen lock vs app minimize scenarios
- Auto-starts timer on app minimize (if not already running)
- Auto-dismisses alarm on screen lock or app minimize

## Integration Points

### iOS System Integration
- **UserNotifications**: Background timer alerts
- **UIApplication**: Background task management
- **NotificationCenter**: App lifecycle events
- **Combine**: Reactive timer updates

### SwiftUI Integration
- **@EnvironmentObject**: ViewModel injection
- **@Published**: Automatic UI updates
- **@StateObject**: ViewModel lifecycle management

## Testing Architecture

### Unit Tests
- **File**: `GymRestTimerTests.swift`
- Basic XCTest structure (currently placeholder)

### UI Tests
- **Files**: `GymRestTimerUITests.swift`, `GymRestTimerUITestsLaunchTests.swift`
- Automated UI testing framework

## Build Configuration

### Xcode Project
- **File**: `GymRestTimer.xcodeproj/project.pbxproj`
- iOS deployment target and build settings
- Asset catalog integration for app icons and colors

### Assets
- **AppIcon**: Multi-variant app icon with dark/tinted appearances
- **AccentColor**: App-wide color theming

## Security & Privacy

### Notification Permissions
- Requests user authorization for alerts, badges, and sounds
- Uses critical sound alerts for timer completion
- Respects user's notification preferences

### Background Processing
- Limited background execution time
- Proper background task management
- State preservation for app resume
