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

    // Hours: 0-12 (timer format, not 24-hour clock)
    @State private var selectedHours: Int = 0

    // Minutes: 0-59 (standard time convention)
    @State private var selectedMinutes: Int = 0

    // Seconds: 0-60 (we include 60 for full minute)
    @State private var selectedSeconds: Int = 0

    // MARK: - Body

    var body: some View {
        // VStack arranges views vertically (top to bottom)
        VStack(spacing: 20) {
            // Title to show what we're selecting
            Text("Set Timer")
                .font(.title2)
                .fontWeight(.semibold)

            // MARK: - Time Display
            // Display the currently selected time in HH:MM:SS format
            // String(format:) is like printf in C - lets us control number formatting
            // %02d means: decimal integer, minimum 2 digits, pad with 0s
            // Example: 5 becomes "05", 30 stays "30"
            // We now show three values: hours:minutes:seconds
            Text(String(format: "%02d:%02d:%02d", selectedHours, selectedMinutes, selectedSeconds))
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundColor(.blue)
                .monospacedDigit()  // Uses monospaced numbers so width doesn't change when digits change

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
                    // Why 0-12? Timer convention (12 hours max for most timers)
                    // If you needed longer timers, you could increase this range
                    Picker("Hours", selection: $selectedHours) {
                        // 0...12 creates a range from 0 to 12 (13 total values)
                        // 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
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
                    // Why 0-59? Standard time convention (60 minutes = 1 hour)
                    Picker("Minutes", selection: $selectedMinutes) {
                        // 0...59 creates a range from 0 to 59 (60 total values)
                        ForEach(0...59, id: \.self) { minute in
                            Text("\(minute)")
                                .font(.title)
                                .tag(minute)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100, height: 150)  // width: 100 gives enough room for 2-digit numbers
                    .clipped()
                }

                // MARK: - Seconds Wheel (RIGHT)
                VStack(spacing: 8) {
                    // Label above the seconds wheel
                    Text("seconds")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    // Seconds Picker: 0-60
                    // Why 0-60? We include 60 to allow full minute (60 seconds = 1 minute)
                    Picker("Seconds", selection: $selectedSeconds) {
                        // 0...60 creates a range from 0 to 60 (61 total values)
                        ForEach(0...60, id: \.self) { second in
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

            // MARK: - Helper Text

            Text("Set your timer duration")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()  // Adds spacing around the entire VStack
    }

    // MARK: - No helper functions needed yet
    // When we add timer functionality, we'll add functions here like:
    // - startTimer()
    // - stopTimer()
    // - resetTimer()
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
