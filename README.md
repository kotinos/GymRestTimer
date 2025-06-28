# GymRestTimer

A SwiftUI-based iOS application designed to help gym users manage rest periods between exercise sets with visual countdown timers and background notifications.

## Features

- **Configurable Rest Timer**: 15-300 seconds in 15-second increments
- **Visual Progress Indicator**: Circular countdown display with smooth animations
- **Background Notifications**: Critical sound alerts even when app is closed or phone is silent
- **Smart App Lifecycle Handling**: Auto-start timer on app minimize, auto-dismiss alarm on screen lock
- **Dark Mode Support**: Follows system appearance with tinted app icon variants
- **MVVM Architecture**: Clean separation of concerns using SwiftUI and Combine

## Screenshots

*Timer Display*
- Circular progress indicator with time remaining
- Start/Stop controls with color-coded buttons
- Duration settings stepper

*Alarm Interface*
- Full-screen alarm when timer completes
- Clear dismiss action to start next set

## Architecture

GymRestTimer follows the **Model-View-ViewModel (MVVM)** pattern:

- **Model**: Timer state and configuration data
- **View**: SwiftUI views (ContentView, AlarmView)
- **ViewModel**: WorkoutViewModel managing business logic and state

### Key Components

- `GymRestTimerApp`: App entry point with dependency injection
- `WorkoutViewModel`: Central state manager with reactive properties
- `ContentView`: Main timer interface with circular progress display
- `AlarmView`: Modal overlay for timer completion
- `NotificationManager`: Background notification service

## Technical Details

### Requirements
- iOS 14.0+
- Xcode 12.0+
- Swift 5.3+

### Frameworks Used
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for timer updates
- **UserNotifications**: Background alerts and critical sounds
- **UIKit**: App lifecycle and background task management

### Key Features Implementation

**Timer Management**
- Uses Combine's `Timer.publish()` for reactive updates
- Preserves state during app backgrounding with `timerEndDate`
- Automatic UI synchronization via `@Published` properties

**Background Handling**
- Distinguishes between screen lock and app minimize
- Auto-starts timer when app is minimized (if not already running)
- Auto-dismisses alarm on screen lock to prevent battery drain

**Notification System**
- Critical sound alerts that bypass silent mode
- Time-sensitive interruption level for immediate attention
- Automatic cleanup of pending notifications

## Documentation

- [Architecture Overview](ARCHITECTURE.md) - Detailed system design and patterns
- [API Reference](API_REFERENCE.md) - Complete method and property documentation
- [Component Interactions](COMPONENT_INTERACTIONS.md) - Data flow and integration details
- [Visual Diagrams](DIAGRAMS.md) - System architecture and state machine diagrams

## Development

### Building
This project requires Xcode and macOS for building and testing. The app cannot be built on Linux environments.

### Testing
- Unit tests: `GymRestTimerTests.swift`
- UI tests: `GymRestTimerUITests.swift`

### Project Structure
```
GymRestTimer/
├── GymRestTimer/           # Main app source
├── GymRestTimerTests/      # Unit tests
├── GymRestTimerUITests/    # UI automation tests
└── GymRestTimer.xcodeproj/ # Xcode project
```

## Usage

1. **Set Duration**: Use the stepper to configure rest time (15-300 seconds)
2. **Start Timer**: Tap "START REST" to begin countdown
3. **Background Use**: App continues timing even when minimized or screen is locked
4. **Timer Completion**: Alarm appears with sound alert when time expires
5. **Next Set**: Tap "Dismiss & Start Next Set" to reset for next exercise

### Smart Behaviors

- **App Minimize**: Automatically starts timer if not already running
- **Screen Lock**: Automatically dismisses alarm to save battery
- **Background Recovery**: Syncs timer state when returning to app
- **Notification Permissions**: Requests access for background alerts

## License

[Add your license information here]

## Contributing

[Add contribution guidelines here]
