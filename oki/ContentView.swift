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

    @State private var selectedMinutes: Int = 10

    @State private var selectedSeconds: Int = 0

    // MARK: - Body

    var body: some View {
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

                    // Minutes Picker: 0, 10, 20, 30, 40, 50
                    // Using stride to create increments of 10 instead of every value
                    Picker("Minutes", selection: $selectedMinutes) {
                        ForEach(Array(stride(from: 0, through: 50, by: 10)), id: \.self) { minute in
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

                    // Seconds Picker: 0-59
                    Picker("Seconds", selection: $selectedSeconds) {
                        ForEach(0...59, id: \.self) { second in
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
        }
        .padding()  // Adds spacing around the entire VStack
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
