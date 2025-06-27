//
//  AlarmView.swift
//  GymRestTimer
//
//  Created by Aaron Lin on 6/27/25.
//


// AlarmView.swift

import SwiftUI

struct AlarmView: View {
    @EnvironmentObject var viewModel: WorkoutViewModel

    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "alarm.fill")
                .font(.system(size: 80))
                .foregroundColor(.white)

            Text("REST OVER!")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(.white)

            Text("Time for your next set.")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))

            Button(action: {
                // When this button is tapped, it tells the ViewModel to stop the alarm.
                viewModel.stopAlarmAndReset()
            }) {
                Text("Dismiss & Start Next Set")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.white)
                    .foregroundColor(.blue)
                    .cornerRadius(15)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.blue)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    AlarmView()
        .environmentObject(WorkoutViewModel())
}
