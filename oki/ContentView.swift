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
            // Display the currently selected time in MM:SS format
            // String(format:) is like printf in C - lets us control number formatting
            // %02d means: decimal integer, minimum 2 digits, pad with 0s
            // Example: 5 becomes "05", 30 stays "30"
            Text(String(format: "%02d:%02d", selectedMinutes, selectedSeconds))
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundColor(.blue)
                .monospacedDigit()  // Uses monospaced numbers so width doesn't change when digits change

            // MARK: - The Time Picker Wheels

            // HStack arranges views horizontally (left to right)
            // spacing: 0 puts the wheels right next to each other (like iOS Clock app)
            HStack(spacing: 0) {

                // MARK: - Minutes Wheel (LEFT)
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
