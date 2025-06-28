# GymRestTimer Visual Diagrams

## System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           GymRestTimer iOS App                              │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                        Presentation Layer                               │ │
│  │                                                                         │ │
│  │  ┌─────────────────┐              ┌─────────────────┐                  │ │
│  │  │   ContentView   │              │   AlarmView     │                  │ │
│  │  │                 │              │                 │                  │ │
│  │  │ • Timer Display │              │ • Alarm Modal   │                  │ │
│  │  │ • Controls      │              │ • Dismiss Button│                  │ │
│  │  │ • Settings      │              │                 │                  │ │
│  │  └─────────────────┘              └─────────────────┘                  │ │
│  │           │                                │                           │ │
│  │           └────────────┬───────────────────┘                           │ │
│  │                        │ @EnvironmentObject                            │ │
│  └────────────────────────┼─────────────────────────────────────────────────┘ │
│                           │                                                 │
│  ┌────────────────────────┼─────────────────────────────────────────────────┐ │
│  │                        │           Business Logic Layer                 │ │
│  │                        ▼                                                 │ │
│  │              ┌─────────────────┐                                        │ │
│  │              │WorkoutViewModel │                                        │ │
│  │              │                 │                                        │ │
│  │              │ @Published:     │                                        │ │
│  │              │ • isResting     │                                        │ │
│  │              │ • isAlarmActive │                                        │ │
│  │              │ • timeString    │                                        │ │
│  │              │ • progress      │                                        │ │
│  │              │ • restDuration  │                                        │ │
│  │              └─────────────────┘                                        │ │
│  │                        │                                                 │ │
│  └────────────────────────┼─────────────────────────────────────────────────┘ │
│                           │                                                 │
│  ┌────────────────────────┼─────────────────────────────────────────────────┐ │
│  │                        │              Service Layer                     │ │
│  │                        ▼                                                 │ │
│  │         ┌─────────────────────┐              ┌─────────────────────┐    │ │
│  │         │ NotificationManager │              │  Combine Framework  │    │ │
│  │         │                     │              │                     │    │ │
│  │         │ • Singleton         │              │ • Timer Publishers  │    │ │
│  │         │ • Schedule alerts   │              │ • Reactive Streams  │    │ │
│  │         │ • Cancel alerts     │              │ • Auto-cancellation│    │ │
│  │         └─────────────────────┘              └─────────────────────┘    │ │
│  │                   │                                    │                │ │
│  └───────────────────┼────────────────────────────────────┼────────────────┘ │
│                      │                                    │                │
│  ┌───────────────────┼────────────────────────────────────┼────────────────┐ │
│  │                   │              System Layer          │                │ │
│  │                   ▼                                    ▼                │ │
│  │    ┌─────────────────────┐              ┌─────────────────────┐         │ │
│  │    │ iOS Notifications   │              │    SwiftUI Engine   │         │ │
│  │    │                     │              │                     │         │ │
│  │    │ • Background alerts │              │ • Reactive UI       │         │ │
│  │    │ • Critical sounds   │              │ • State binding     │         │ │
│  │    │ • Lock screen       │              │ • View updates      │         │ │
│  │    └─────────────────────┘              └─────────────────────┘         │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

## MVVM Pattern Implementation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              MVVM Pattern                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                               VIEW                                      │ │
│  │                                                                         │ │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐     │ │
│  │  │   ContentView   │    │   AlarmView     │    │GymRestTimerApp  │     │ │
│  │  │                 │    │                 │    │                 │     │ │
│  │  │ • UI Elements   │    │ • Modal UI      │    │ • App Entry     │     │ │
│  │  │ • User Input    │    │ • Dismiss       │    │ • DI Container  │     │ │
│  │  │ • Display       │    │                 │    │                 │     │ │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────┘     │ │
│  │           │                       │                       │            │ │
│  │           │ @EnvironmentObject    │ @EnvironmentObject    │ @StateObject│ │
│  │           │                       │                       │            │ │
│  └───────────┼───────────────────────┼───────────────────────┼────────────┘ │
│              │                       │                       │              │
│              └───────────────────────┼───────────────────────┘              │
│                                      │                                      │
│  ┌───────────────────────────────────┼──────────────────────────────────────┐ │
│  │                                   │            VIEW MODEL               │ │
│  │                                   ▼                                     │ │
│  │                        ┌─────────────────┐                             │ │
│  │                        │WorkoutViewModel │                             │ │
│  │                        │                 │                             │ │
│  │                        │ Business Logic: │                             │ │
│  │                        │ • Timer Control │                             │ │
│  │                        │ • State Mgmt    │                             │ │
│  │                        │ • App Lifecycle │                             │ │
│  │                        │                 │                             │ │
│  │                        │ @Published:     │                             │ │
│  │                        │ • UI State      │                             │ │
│  │                        │ • Data Binding  │                             │ │
│  │                        └─────────────────┘                             │ │
│  │                                   │                                     │ │
│  └───────────────────────────────────┼─────────────────────────────────────┘ │
│                                      │                                      │
│  ┌───────────────────────────────────┼──────────────────────────────────────┐ │
│  │                                   │              MODEL                  │ │
│  │                                   ▼                                     │ │
│  │              ┌─────────────────────────────────────────┐                │ │
│  │              │              Timer State                │                │ │
│  │              │                                         │                │ │
│  │              │ • isResting: Bool                       │                │ │
│  │              │ • restDuration: TimeInterval            │                │ │
│  │              │ • timerEndDate: Date?                   │                │ │
│  │              │ • timeString: String                    │                │ │
│  │              │ • progress: Double                      │                │ │
│  │              │ • isAlarmActive: Bool                   │                │ │
│  │              └─────────────────────────────────────────┘                │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Timer State Machine

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Timer State Machine                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                              ┌─────────────┐                               │
│                              │    IDLE     │                               │
│                              │             │                               │
│                              │ isResting:  │                               │
│                              │   false     │                               │
│                              │ progress:   │                               │
│                              │   1.0       │                               │
│                              └─────────────┘                               │
│                                     │                                      │
│                                     │ User taps                            │
│                                     │ "START REST"                         │
│                                     ▼                                      │
│                              ┌─────────────┐                               │
│                              │   ACTIVE    │                               │
│                              │             │                               │
│                              │ isResting:  │                               │
│                              │   true      │                               │
│                              │ timer:      │                               │
│                              │   running   │                               │
│                              │ progress:   │                               │
│                              │   0.0-1.0   │                               │
│                              └─────────────┘                               │
│                                     │                                      │
│                          ┌──────────┼──────────┐                          │
│                          │          │          │                          │
│                   User taps    Timer expires   User taps                   │
│                  "STOP REST"        │       "END WORKOUT"                  │
│                          │          │          │                          │
│                          ▼          ▼          ▼                          │
│                   ┌─────────────┐ ┌─────────────┐ ┌─────────────┐         │
│                   │    IDLE     │ │   ALARM     │ │    IDLE     │         │
│                   │             │ │             │ │             │         │
│                   │ (Reset to   │ │ isAlarmActive│ │ (Reset to   │         │
│                   │  initial)   │ │   true      │ │  initial)   │         │
│                   └─────────────┘ │ timeString: │ └─────────────┘         │
│                                   │   "00:00"   │                         │
│                                   │ progress:   │                         │
│                                   │   0.0       │                         │
│                                   └─────────────┘                         │
│                                          │                                 │
│                                          │ User taps                       │
│                                          │ "Dismiss"                       │
│                                          ▼                                 │
│                                   ┌─────────────┐                         │
│                                   │    IDLE     │                         │
│                                   │             │                         │
│                                   │ (Reset to   │                         │
│                                   │  initial)   │                         │
│                                   └─────────────┘                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## App Lifecycle Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          App Lifecycle Management                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────┐                                                       │
│  │ App Foreground  │                                                       │
│  │                 │                                                       │
│  │ • Timer active  │                                                       │
│  │ • UI updates    │                                                       │
│  │ • User interact │                                                       │
│  └─────────────────┘                                                       │
│           │                                                                │
│           │ willResignActive                                               │
│           ▼                                                                │
│  ┌─────────────────┐                                                       │
│  │ Transition      │                                                       │
│  │                 │                                                       │
│  │ • Record time   │                                                       │
│  │ • Start bg task │                                                       │
│  │ • Set flags     │                                                       │
│  └─────────────────┘                                                       │
│           │                                                                │
│           ├─────────────────┬─────────────────┐                           │
│           │                 │                 │                           │
│           ▼                 ▼                 ▼                           │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐             │
│  │ Screen Lock     │ │ App Minimize    │ │ App Background  │             │
│  │                 │ │                 │ │                 │             │
│  │ • Power button  │ │ • Home button   │ │ • System event  │             │
│  │ • Auto-dismiss  │ │ • Auto-start    │ │ • Preserve state│             │
│  │   alarm         │ │   timer         │ │                 │             │
│  └─────────────────┘ └─────────────────┘ └─────────────────┘             │
│           │                 │                 │                           │
│           │                 │                 │                           │
│           └─────────────────┼─────────────────┘                           │
│                             │                                             │
│                             │ didBecomeActive                             │
│                             ▼                                             │
│                    ┌─────────────────┐                                    │
│                    │ App Foreground  │                                    │
│                    │                 │                                    │
│                    │ • Check expiry  │                                    │
│                    │ • Sync UI state │                                    │
│                    │ • End bg task   │                                    │
│                    └─────────────────┘                                    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Notification System Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         Notification System Flow                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────┐                                                       │
│  │ Timer Started   │                                                       │
│  │                 │                                                       │
│  │ User taps       │                                                       │
│  │ "START REST"    │                                                       │
│  └─────────────────┘                                                       │
│           │                                                                │
│           ▼                                                                │
│  ┌─────────────────┐                                                       │
│  │ Schedule        │                                                       │
│  │ Notification    │                                                       │
│  │                 │                                                       │
│  │ • Cancel prev   │                                                       │
│  │ • Set content   │                                                       │
│  │ • Critical sound│                                                       │
│  │ • Time trigger  │                                                       │
│  └─────────────────┘                                                       │
│           │                                                                │
│           ▼                                                                │
│  ┌─────────────────┐                                                       │
│  │ iOS System      │                                                       │
│  │ Notification    │                                                       │
│  │                 │                                                       │
│  │ • Pending in    │                                                       │
│  │   system queue  │                                                       │
│  │ • Waits for     │                                                       │
│  │   trigger time  │                                                       │
│  └─────────────────┘                                                       │
│           │                                                                │
│           ├─────────────────┬─────────────────┐                           │
│           │                 │                 │                           │
│           ▼                 ▼                 ▼                           │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐             │
│  │ App Foreground  │ │ App Background  │ │ Timer Cancelled │             │
│  │                 │ │                 │ │                 │             │
│  │ • Show alarm    │ │ • Lock screen   │ │ • Remove from   │             │
│  │   in app        │ │   notification  │ │   system queue  │             │
│  │ • Play sound    │ │ • Badge update  │ │ • No alert      │             │
│  │ • Full screen   │ │ • Critical sound│ │                 │             │
│  └─────────────────┘ └─────────────────┘ └─────────────────┘             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Data Binding Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        SwiftUI Data Binding Flow                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                        WorkoutViewModel                                 │ │
│  │                                                                         │ │
│  │  @Published var isResting: Bool = false                                │ │
│  │  @Published var timeString: String = "01:30"                           │ │
│  │  @Published var progress: Double = 1.0                                 │ │
│  │  @Published var isAlarmActive: Bool = false                            │ │
│  │  @Published var restDuration: TimeInterval = 90                        │ │
│  │                                                                         │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                      │                                      │
│                                      │ @EnvironmentObject                  │
│                                      ▼                                      │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                           ContentView                                   │ │
│  │                                                                         │ │
│  │  Text(viewModel.timeString)           ← timeString                     │ │
│  │  Circle().trim(to: viewModel.progress) ← progress                      │ │
│  │  Button(viewModel.isResting ? "STOP" : "START") ← isResting            │ │
│  │  Stepper(value: $viewModel.restDuration) ← restDuration (two-way)      │ │
│  │  .blur(radius: viewModel.isAlarmActive ? 20 : 0) ← isAlarmActive       │ │
│  │                                                                         │ │
│  │  if viewModel.isAlarmActive {                                          │ │
│  │      AlarmView()                                                        │ │
│  │  }                                                                      │ │
│  │                                                                         │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                      │                                      │
│                                      │ @EnvironmentObject                  │
│                                      ▼                                      │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                            AlarmView                                    │ │
│  │                                                                         │ │
│  │  Button("Dismiss") {                                                    │ │
│  │      viewModel.stopAlarmAndReset()                                      │ │
│  │  }                                                                      │ │
│  │                                                                         │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                        Automatic Updates                                │ │
│  │                                                                         │ │
│  │  Property Change → @Published → SwiftUI → View Update                  │ │
│  │                                                                         │ │
│  │  User Interaction → View Action → ViewModel Method → Property Change   │ │
│  │                                                                         │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

## File Structure Diagram

```
GymRestTimer/
├── GymRestTimer/
│   ├── GymRestTimerApp.swift          ← App Entry Point
│   │   └── @main struct
│   │       ├── @StateObject WorkoutViewModel
│   │       └── WindowGroup with ContentView
│   │
│   ├── ContentView.swift              ← Main UI View
│   │   └── struct ContentView: View
│   │       ├── @EnvironmentObject WorkoutViewModel
│   │       ├── Timer Display (ZStack with Circles)
│   │       ├── Action Buttons (Start/Stop/End)
│   │       ├── Settings (Duration Stepper)
│   │       └── App Lifecycle Observers
│   │
│   ├── AlarmView.swift                ← Timer Completion Modal
│   │   └── struct AlarmView: View
│   │       ├── @EnvironmentObject WorkoutViewModel
│   │       ├── Alarm Icon & Text
│   │       └── Dismiss Button
│   │
│   ├── WorkoutViewModel.swift         ← Business Logic (MVVM)
│   │   └── @MainActor class WorkoutViewModel: ObservableObject
│   │       ├── @Published Properties (State)
│   │       ├── Private Timer Management
│   │       ├── App Lifecycle Handlers
│   │       ├── Background Task Management
│   │       └── Notification Integration
│   │
│   ├── NotificationManager.swift      ← Background Alerts
│   │   └── class NotificationManager (Singleton)
│   │       ├── Authorization Request
│   │       ├── Schedule Notifications
│   │       └── Cancel Notifications
│   │
│   └── Assets.xcassets/               ← Visual Assets
│       ├── AppIcon.appiconset/
│       └── AccentColor.colorset/
│
├── GymRestTimerTests/
│   └── GymRestTimerTests.swift        ← Unit Tests
│
├── GymRestTimerUITests/
│   ├── GymRestTimerUITests.swift      ← UI Tests
│   └── GymRestTimerUITestsLaunchTests.swift
│
└── GymRestTimer.xcodeproj/            ← Xcode Project
    └── project.pbxproj                ← Build Configuration
```
