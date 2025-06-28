// ContentView.swift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: WorkoutViewModel
    
    var body: some View {
        ZStack {
            // Main UI
            VStack(spacing: 40) {
                header
                timerDisplay
                actionButton
                endWorkoutButton
                settings
            }
            .padding()
            .blur(radius: viewModel.isAlarmActive ? 20 : 0)
            
            // Alarm View that appears on top when the timer finishes
            if viewModel.isAlarmActive {
                AlarmView()
            }
        }
        // Lifecycle notifications
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            viewModel.handleAppWillResignActive()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            viewModel.handleAppDidEnterBackground()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            viewModel.handleAppMovedToForeground()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIScene.didEnterBackgroundNotification)) { _ in
            viewModel.handleSceneDidEnterBackground()
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
    
    private var endWorkoutButton: some View {
        Button(action: {
            viewModel.endWorkout()
        }) {
            Text("END WORKOUT")
                .font(.title3)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.orange)
                .foregroundColor(.white)
                .cornerRadius(15)
        }
    }
    
    private var settings: some View {
        Stepper("Rest for $Int(viewModel.restDuration)) seconds",
                value: $viewModel.restDuration,
                in: 15...300,
                step: 15)
        .padding(.horizontal)
        .disabled(viewModel.isResting)
    }
}

#Preview {
    ContentView()
        .environmentObject(WorkoutViewModel())
}
