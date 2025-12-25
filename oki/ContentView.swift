//
//  ContentView.swift
//  oki
//
//  Created by Viktorija Leimane on 24/12/2025.
//

import SwiftUI
import SwiftData
import UIKit  // For haptic feedback

// MARK: - Bell Option Enum

// Enum for starting bell options
// iOS best practice: Use enums for mutually exclusive states
enum BellOption: String, CaseIterable {
    case none = "None"
    case vibrate = "Vibrate"

    // SF Symbol icon for each option
    var icon: String {
        switch self {
        case .none:
            return "speaker.slash.fill"
        case .vibrate:
            return "bell.fill"
        }
    }
}

struct ContentView: View {
    // MARK: - State Properties

    // @State variables track the currently selected values
    // These update automatically when the user spins the wheels
    // SwiftUI re-renders the view whenever these change

    @State private var selectedHours: Int = 0

    @State private var selectedMinutes: Int = 2

    @State private var selectedSeconds: Int = 0

    // Bell option state - controls whether to vibrate when timer completes
    @State private var selectedBellOption: BellOption = .none

    // Navigation state - controls whether we show the countdown timer
    @State private var showingTimer: Bool = false

    // MARK: - Body

    var body: some View {
        // NavigationStack enables navigation to the timer view
        NavigationStack {
            // VStack arranges views vertically (top to bottom)
            VStack(spacing: 20) {
                // MARK: - Starting Bell Section

                Text("Starting bell")
                    .font(.title2)
                    .fontWeight(.semibold)

                // HStack for the two bell options
                HStack(spacing: 30) {
                    // Silent/None option
                    BellOptionButton(
                        option: .none,
                        isSelected: selectedBellOption == .none
                    ) {
                        selectedBellOption = .none
                    }

                    // Vibrate option
                    BellOptionButton(
                        option: .vibrate,
                        isSelected: selectedBellOption == .vibrate
                    ) {
                        selectedBellOption = .vibrate
                    }
                }
                .padding(.bottom, 20)

                // MARK: - Duration Section

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
                    seconds: selectedSeconds,
                    bellOption: selectedBellOption
                )
            }
        }
    }
}

// MARK: - Bell Option Button

// Reusable button component for bell options
// iOS best practice: Extract reusable UI components
struct BellOptionButton: View {
    let option: BellOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // SF Symbol icon
                Image(systemName: option.icon)
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? .blue : .gray)

                // Option label
                Text(option.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .frame(width: 100, height: 80)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
            )
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
    let bellOption: BellOption

    // State for the countdown
    // @State lets us modify these values as the timer counts down
    @State private var remainingSeconds: Int = 0

    // Timer that fires every second
    // The timer will update remainingSeconds every second
    @State private var timer: Timer?

    // Tracks whether the timer is paused
    // iOS best practice: Use a single boolean state for play/pause toggle
    @State private var isPaused: Bool = false

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

            // MARK: - Pause/Play Button

            // iOS best practice: Use SF Symbols for system icons
            // Single button that toggles between pause and play states
            Button(action: {
                togglePauseResume()
            }) {
                Image(systemName: isPaused ? "play.fill" : "pause.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
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
            // Only decrement if not paused
            // iOS best practice: Check state before modifying
            if !isPaused && remainingSeconds > 0 {
                remainingSeconds -= 1  // Decrease by 1 second
            } else if remainingSeconds == 0 {
                // Timer finished - stop the timer
                stopTimer()

                // Trigger haptic feedback if vibrate option is selected
                // iOS best practice: Use UINotificationFeedbackGenerator for completion events
                if bellOption == .vibrate {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            }
        }
    }

    // Stops and cleans up the timer
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // Toggles between pause and resume states
    // iOS best practice: Single function for toggle behavior
    private func togglePauseResume() {
        isPaused.toggle()  // Flip the boolean: true -> false, false -> true
        // Timer continues running but checks isPaused before decrementing
        // This is more efficient than stopping/starting timer
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
