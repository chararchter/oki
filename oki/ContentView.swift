//
//  ContentView.swift
//  oki
//
//  Created by Viktorija Leimane on 24/12/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // MARK: - State Properties

    // @State variables track the currently selected values
    // These update automatically when the user spins the wheels
    // SwiftUI re-renders the view whenever these change

    @State private var selectedHours: Int = 0

    @State private var selectedMinutes: Int = 2

    @State private var selectedSeconds: Int = 0

    // Navigation state - controls whether we show the countdown timer
    @State private var showingTimer: Bool = false

    // MARK: - Body

    var body: some View {
        // NavigationStack enables navigation to the timer view
        NavigationStack {
            // VStack arranges views vertically (top to bottom)
            VStack(spacing: 20) {
                // Title to show what we're selecting
                Text("Duration")
                    .font(.title2)
                    .fontWeight(.semibold)


                // MARK: - The Time Picker Wheels

                // HStack arranges views horizontally (left to right)
                // spacing: 0 puts the wheels right next to each other (like iOS Clock app)
                // Order: Hours (left) → Minutes (middle) → Seconds (right)
                HStack(spacing: 0) {

                    // MARK: - Hours Wheel (LEFT)
                    VStack(spacing: 8) {
                        // Label above the hours wheel
                        Text("hours")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        // Hours Picker: 0-12
                        // Could potentially increase this range but who meditates more than 12 hours?
                        Picker("Hours", selection: $selectedHours) {
                            ForEach(0...12, id: \.self) { hour in
                                Text("\(hour)")
                                    .font(.title)
                                    .tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 150)  // width: 100 gives enough room for 2-digit numbers
                        .clipped()
                    }

                    // MARK: - Minutes Wheel (MIDDLE)
                    VStack(spacing: 8) {
                        // Label above the minutes wheel
                        Text("minutes")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        // Minutes Picker: 0-59
                        Picker("Minutes", selection: $selectedMinutes) {
                            ForEach(0...59, id: \.self) { minute in
                                Text("\(minute)")
                                    .font(.title)
                                    .tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 150)
                        .clipped()
                    }

                    // MARK: - Seconds Wheel (RIGHT)
                    VStack(spacing: 8) {
                        // Label above the seconds wheel
                        Text("seconds")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        // Seconds Picker: 0, 10, 20, 30, 40, 50
                        Picker("Seconds", selection: $selectedSeconds) {
                            ForEach(Array(stride(from: 0, through: 50, by: 10)), id: \.self) { second in
                                Text("\(second)")
                                    .font(.title)
                                    .tag(second)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 150)
                        .clipped()
                    }
                }

                // MARK: - Start Button

                // NavigationLink presents the timer view when tapped
                // We use .navigationDestination to specify where to navigate
                Button(action: {
                    showingTimer = true
                }) {
                    Text("start")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 100, height: 100)  // Makes it a large round button
                        .background(Color.red)
                        .clipShape(Circle())  // Makes it perfectly round
                }
                .padding(.top, 30)  // Add space between wheels and button
            }
            .padding()  // Adds spacing around the entire VStack
            // NavigationDestination: When showingTimer is true, navigate to TimerView
            .navigationDestination(isPresented: $showingTimer) {
                TimerView(
                    hours: selectedHours,
                    minutes: selectedMinutes,
                    seconds: selectedSeconds
                )
            }
        }
    }
}

// MARK: - Timer View

// This view displays the countdown timer
struct TimerView: View {
    // The initial time values passed from ContentView
    let hours: Int
    let minutes: Int
    let seconds: Int

    // State for the countdown
    // @State lets us modify these values as the timer counts down
    @State private var remainingSeconds: Int = 0

    // Timer that fires every second
    // The timer will update remainingSeconds every second
    @State private var timer: Timer?

    // Environment value to dismiss this view (go back to ContentView)
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 40) {
            // MARK: - Countdown Display

            // Display remaining time in HH:MM:SS format
            // This updates every second as the timer counts down
            Text(formattedTime)
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .monospacedDigit()  // Keeps digits the same width

            // Optional: Show progress or other controls here
        }
        .padding()
        .navigationBarBackButtonHidden(false)  // Show back button to return to duration picker
        // onAppear runs when this view first appears
        .onAppear {
            startTimer()
        }
        // onDisappear runs when leaving this view
        .onDisappear {
            stopTimer()
        }
    }

    // MARK: - Helper Functions

    // Converts hours, minutes, seconds to total seconds
    // Called when view appears to set up initial countdown value
    private func startTimer() {
        // Calculate total seconds from hours, minutes, seconds
        remainingSeconds = (hours * 3600) + (minutes * 60) + seconds

        // Create a timer that fires every 1 second
        // Timer.publish creates a publisher that emits events on a schedule
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if remainingSeconds > 0 {
                remainingSeconds -= 1  // Decrease by 1 second
            } else {
                // Timer finished - stop the timer
                stopTimer()
                // Optional: Add sound, haptic feedback, or dismiss view
            }
        }
    }

    // Stops and cleans up the timer
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // Formats remainingSeconds into MM:SS or HH:MM:SS string
    // This computed property recalculates whenever remainingSeconds changes
    private var formattedTime: String {
        let hours = remainingSeconds / 3600  // 3600 seconds in an hour
        let minutes = (remainingSeconds % 3600) / 60  // Remaining seconds / 60
        let seconds = remainingSeconds % 60  // Leftover seconds

        // Conditional formatting:
        // If hours == 0: show MM:SS (e.g., "05:30")
        // If hours > 0: show HH:MM:SS (e.g., "02:05:30")
        if hours == 0 {
            return String(format: "%02d:%02d", minutes, seconds)
        } else {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
