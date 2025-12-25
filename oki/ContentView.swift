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

    // @State is a property wrapper that tells SwiftUI to watch this variable for changes
    // When selectedSeconds changes, SwiftUI automatically re-renders the view
    // We start at 0 seconds by default
    @State private var selectedSeconds: Int = 0

    // MARK: - Body

    var body: some View {
        // VStack arranges views vertically (top to bottom)
        VStack(spacing: 20) {
            // Title to show what we're selecting
            Text("Select Seconds")
                .font(.title2)
                .fontWeight(.semibold)

            // Display the currently selected value
            // This updates in real-time as the user spins the wheel
            Text("\(selectedSeconds) sec")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.blue)

            // MARK: - The Seconds Wheel Picker

            // Picker is the main component
            // - First parameter: A label (required but hidden when using .wheel style)
            // - selection: A binding to our state variable using $ prefix
            //   The $ creates a two-way binding so the picker can read AND write to selectedSeconds
            Picker("Seconds", selection: $selectedSeconds) {
                // ForEach loops through a range of values
                // 0...60 creates a closed range from 0 to 60 (inclusive on both ends)
                // id: \.self tells SwiftUI to use the number itself as a unique identifier
                ForEach(0...60, id: \.self) { second in
                    // Each item in the picker needs a Text view
                    // \(second) converts the integer to a string for display
                    // .tag(second) associates this view with the value 'second'
                    // When this item is selected, selectedSeconds will be set to this tag value
                    Text("\(second)")
                        .font(.title)  // Makes the numbers larger and easier to read
                        .tag(second)   // This is crucial - it's the value that gets stored in selectedSeconds
                }
            }
            // .pickerStyle(.wheel) gives us the native iOS spinning wheel
            // This is the same style used in:
            // - Clock app for setting timers
            // - Date & Time pickers
            // - Settings for various options
            .pickerStyle(.wheel)
            // frame sets the size of the picker
            // height: 150 is a good size - not too tall, not too short
            .frame(height: 150)
            // clipped() prevents the picker from drawing outside its frame
            .clipped()

            // MARK: - Helper Text

            Text("Spin the wheel to select seconds")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()  // Adds spacing around the entire VStack
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
