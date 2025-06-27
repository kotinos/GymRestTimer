// ContentView.swift

import SwiftUI

struct ContentView: View {
    // Access the shared ViewModel from the environment.
    @EnvironmentObject var viewModel: WorkoutViewModel

    var body: some View {
        ZStack {
            // Main UI
            VStack(spacing: 40) {
                header
                timerDisplay
                actionButton
                settings
            }
            .padding()
            .blur(radius: viewModel.isAlarmActive ? 20 : 0) // Blur the main UI when the alarm is showing

            // Alarm View that appears on top when the timer finishes
            if viewModel.isAlarmActive {
                AlarmView()
            }
        }
        
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            viewModel.handleAppMovedToBackground()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            viewModel.handleAppMovedToForeground()
        }
    }

    // MARK: - Subviews

    private var header: some View {
        Text("Gym Rest Timer")
            .font(.largeTitle)
            .fontWeight(.bold)
    }

    private var timerDisplay: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.1)
                .foregroundColor(.accentColor)

            Circle()
                .trim(from: 0.0, to: viewModel.progress)
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(.accentColor)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: viewModel.progress)

            Text(viewModel.timeString)
                .font(.system(size: 60, weight: .bold, design: .monospaced))
        }
        .frame(width: 300, height: 300)
    }

    private var actionButton: some View {
        Button(action: {
            viewModel.isResting.toggle()
        }) {
            Text(viewModel.isResting ? "STOP REST" : "START REST")
                .font(.title2)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(viewModel.isResting ? .red : .green)
                .foregroundColor(.white)
                .cornerRadius(15)
        }
    }

    private var settings: some View {
        Stepper("Rest for \(Int(viewModel.restDuration)) seconds",
                value: $viewModel.restDuration,
                in: 15...300, // Rest between 15 seconds and 5 minutes
                step: 15)
        .padding(.horizontal)
        .disabled(viewModel.isResting) // Disable changing time while timer is running
    }
}

#Preview {
    ContentView()
        .environmentObject(WorkoutViewModel())
}
