# GymRestTimer API Reference

## WorkoutViewModel

### Published Properties

#### `isResting: Bool`
- **Default**: `false`
- **Description**: Indicates whether the rest timer is currently active
- **Triggers**: `startRestTimer()` when set to `true`, `stopRestTimer()` when set to `false`
- **UI Binding**: Controls start/stop button text and color

#### `isAlarmActive: Bool`
- **Default**: `false`
- **Description**: Controls the visibility of the AlarmView modal
- **Triggers**: Set to `true` when timer expires, `false` when alarm is dismissed
- **UI Binding**: Shows/hides AlarmView overlay and blurs main content

#### `timeString: String`
- **Default**: `"01:30"`
- **Description**: Formatted time display in "MM:SS" format
- **Updates**: Every second during timer countdown
- **UI Binding**: Main timer display text

#### `progress: Double`
- **Default**: `1.0`
- **Range**: `0.0` to `1.0`
- **Description**: Timer progress for circular progress indicator
- **Calculation**: `remaining time / total duration`
- **UI Binding**: Circular progress bar trim value

#### `restDuration: TimeInterval`
- **Default**: `90` seconds
- **Range**: `15` to `300` seconds (15-second increments)
- **Description**: Configurable timer duration
- **UI Binding**: Stepper control value

### Public Methods

#### `stopAlarmAndReset()`
```swift
func stopAlarmAndReset()
```
- **Purpose**: Dismisses alarm and resets timer state
- **Called by**: AlarmView dismiss button
- **Side effects**: Sets `isAlarmActive = false`, `isResting = false`

#### `endWorkout()`
```swift
func endWorkout()
```
- **Purpose**: Completely stops current workout session
- **Side effects**: 
  - Cancels active timer
  - Resets all state
  - Cancels scheduled notifications
  - Resets progress to 1.0

### App Lifecycle Methods

#### `handleAppWillResignActive()`
```swift
func handleAppWillResignActive()
```
- **Purpose**: Prepares app for background transition
- **Side effects**:
  - Records resign time
  - Starts background task
  - Sets processing flags

#### `handleAppDidEnterBackground()`
```swift
func handleAppDidEnterBackground()
```
- **Purpose**: Handles app backgrounding
- **Side effects**: Schedules background task cleanup

#### `handleSceneDidEnterBackground()`
```swift
func handleSceneDidEnterBackground()
```
- **Purpose**: Detects app minimize vs screen lock
- **Logic**: Delays processing to distinguish between scenarios
- **Side effects**: May trigger auto-start timer on app minimize

#### `handleAppMovedToForeground()`
```swift
func handleAppMovedToForeground()
```
- **Purpose**: Synchronizes timer state when app resumes
- **Side effects**:
  - Checks timer expiration
  - Updates UI state
  - Ends background tasks

### Private Methods

#### `startRestTimer()`
```swift
private func startRestTimer()
```
- **Purpose**: Initiates countdown timer
- **Side effects**:
  - Sets `timerEndDate`
  - Schedules notification
  - Starts Combine timer publisher

#### `stopRestTimer()`
```swift
private func stopRestTimer()
```
- **Purpose**: Stops active timer
- **Side effects**:
  - Cancels timer
  - Resets progress and time display
  - Cancels notifications

#### `updateUI()`
```swift
private func updateUI()
```
- **Purpose**: Updates timer display every second
- **Calculations**:
  - Remaining time from `timerEndDate`
  - Progress percentage
  - Timer expiration detection

#### `formatTime(_ interval: TimeInterval) -> String`
```swift
private func formatTime(_ interval: TimeInterval) -> String
```
- **Purpose**: Converts TimeInterval to "MM:SS" format
- **Returns**: Formatted string (e.g., "01:30")

## NotificationManager

### Singleton Instance
```swift
static let shared = NotificationManager()
```

### Public Methods

#### `requestAuthorization()`
```swift
func requestAuthorization()
```
- **Purpose**: Requests notification permissions from user
- **Permissions**: Alert, badge, sound
- **Called by**: App launch in `GymRestTimerApp`

#### `scheduleRestNotification(duration: TimeInterval)`
```swift
func scheduleRestNotification(duration: TimeInterval)
```
- **Purpose**: Schedules background timer completion notification
- **Parameters**:
  - `duration`: Timer duration in seconds
- **Features**:
  - Critical sound (bypasses silent mode)
  - Time-sensitive interruption level
  - Automatic previous notification cancellation

#### `cancelNotifications()`
```swift
func cancelNotifications()
```
- **Purpose**: Cancels all pending notifications
- **Called by**: Timer stop, workout end, manual cancellation

### Notification Configuration

#### Content Properties
- **Title**: "Rest Over!"
- **Subtitle**: "Time for your next set."
- **Sound**: `.defaultCriticalSound(withAudioVolume: 1.0)`
- **Interruption Level**: `.timeSensitive`
- **Identifier**: "GYM_REST_TIMER"

## ContentView

### Environment Objects
```swift
@EnvironmentObject var viewModel: WorkoutViewModel
```

### Subviews

#### `header`
```swift
private var header: some View
```
- **Content**: "Gym Rest Timer" title
- **Styling**: Large title, bold weight

#### `timerDisplay`
```swift
private var timerDisplay: some View
```
- **Components**:
  - Background circle (opacity 0.1)
  - Progress circle (trim based on `viewModel.progress`)
  - Time text (monospaced font, 60pt)
- **Size**: 300x300 points
- **Animation**: Linear progress animation

#### `actionButton`
```swift
private var actionButton: some View
```
- **Text**: "START REST" / "STOP REST"
- **Color**: Green (start) / Red (stop)
- **Action**: Toggles `viewModel.isResting`

#### `endWorkoutButton`
```swift
private var endWorkoutButton: some View
```
- **Text**: "END WORKOUT"
- **Color**: Orange
- **Action**: Calls `viewModel.endWorkout()`

#### `settings`
```swift
private var settings: some View
```
- **Control**: Stepper for rest duration
- **Range**: 15-300 seconds
- **Step**: 15 seconds
- **Disabled**: When timer is active (`viewModel.isResting`)

### App Lifecycle Bindings
- **willResignActive**: `viewModel.handleAppWillResignActive()`
- **didEnterBackground**: `viewModel.handleAppDidEnterBackground()`
- **didBecomeActive**: `viewModel.handleAppMovedToForeground()`
- **sceneDidEnterBackground**: `viewModel.handleSceneDidEnterBackground()`

## AlarmView

### Environment Objects
```swift
@EnvironmentObject var viewModel: WorkoutViewModel
```

### UI Components
- **Icon**: `alarm.fill` system image (80pt)
- **Title**: "REST OVER!" (large title, heavy weight)
- **Subtitle**: "Time for your next set." (title3, 80% opacity)
- **Button**: "Dismiss & Start Next Set"

### Styling
- **Background**: Blue full-screen overlay
- **Text Color**: White
- **Button**: White background, blue text
- **Padding**: 40 points
- **Safe Area**: Ignored (full screen)

### Actions
- **Dismiss Button**: Calls `viewModel.stopAlarmAndReset()`

## GymRestTimerApp

### State Objects
```swift
@StateObject private var workoutViewModel = WorkoutViewModel()
```

### App Configuration
- **Environment Injection**: Provides `workoutViewModel` to all views
- **Notification Setup**: Requests authorization on app appear
- **Window Group**: Single window configuration

## Constants and Configuration

### Timer Settings
- **Minimum Duration**: 15 seconds
- **Maximum Duration**: 300 seconds (5 minutes)
- **Step Increment**: 15 seconds
- **Default Duration**: 90 seconds

### UI Constants
- **Timer Display Size**: 300x300 points
- **Progress Stroke Width**: 20 points
- **Corner Radius**: 15 points
- **Animation Type**: Linear

### Notification Settings
- **Identifier**: "GYM_REST_TIMER"
- **Sound Volume**: 1.0 (maximum)
- **Interruption Level**: Time-sensitive
- **Repeat**: False (one-time notification)
