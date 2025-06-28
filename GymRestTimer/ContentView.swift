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
            Color(.systemGray6)
                .ignoresSafeArea()
            
            ZStack {
                ForEach(0..<60, id: \.self) { tick in
                    Rectangle()
                        .fill(Color.blue.opacity(0.6))
                        .frame(width: tick % 5 == 0 ? 4 : 2, height: tick % 5 == 0 ? 20 : 12)
                        .offset(y: -140)
                        .rotationEffect(.degrees(Double(tick) * 6))
                }
                
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 30)
                    .frame(width: 280, height: 280)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 200, height: 200)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                Circle()
                    .trim(from: 0.0, to: viewModel.progress)
                    .stroke(
                        Color.blue.opacity(0.8),
                        style: StrokeStyle(lineWidth: 30, lineCap: .round)
                    )
                    .frame(width: 280, height: 280)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: viewModel.progress)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                    .offset(y: -140)
                    .rotationEffect(.degrees(Double(1.0 - viewModel.progress) * 360))
                    .animation(.easeInOut(duration: 0.5), value: viewModel.progress)
                
                Text(viewModel.timeString)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
            }
        }
        .frame(width: 350, height: 350)
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
        Stepper("Rest for \(Int(viewModel.restDuration)) seconds",
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
