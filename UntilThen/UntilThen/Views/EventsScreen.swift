//
//  EventsScreen.swift
//  UntilThen
//
//  Created by Jonathan Sweeney on 5/23/26.
//

import SwiftUI
internal import Combine

/// Displays a sorted, swipeable list of events and handles navigation to EventForm
struct EventsScreen: View {

    // MARK: - State

    /// The master list of events, sorted on display
    @State var events: [Event] = []

    /// Bool to show or hide past events
    @State private var showPastEvents: Bool = true
    
    /// Current time - updates every second to refresh filtered events
    @State private var currentTime: Date = .now

    // MARK: - Properties
    
    /// Timer that fires every second to update current time
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    /// All or future events
    private var filteredEvents: [Event] {
        let sorted = events.sorted()
        return showPastEvents ? sorted : sorted.filter { $0.date > currentTime }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {
                if events.isEmpty {
                    ContentUnavailableView(
                        "No Events Yet...",
                        systemImage: "calendar.badge.plus",
                        description: Text("Tap the + icon to add your first event!")
                    )
                } else {
                    ForEach(filteredEvents) { event in
                        NavigationLink(value: EventFormMode.edit(event)) {
                            EventRow(event: event)
                        }
                    }
                    .onDelete(perform: deleteEvent)
                }
            }
            .onReceive(timer) { time in
                currentTime = time
            }
            .navigationTitle(Text("Events"))
            .navigationDestination(for: EventFormMode.self) { mode in
                EventForm(mode: mode, onSave: handleSave)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: EventFormMode.add) {
                        Image(systemName: "plus")
                            .symbolEffect(.bounce, options: .speed(0.3).nonRepeating, isActive: events.isEmpty)
                            .symbolEffect(.pulse, options: .speed(0.5).repeating, isActive: events.isEmpty)
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation {
                            showPastEvents.toggle()
                        }
                    } label: {
                        Image(systemName: showPastEvents ? "clock.fill" : "clock")
                    }
                }
            }
        }
    }

    // MARK: Helpers

    /// Deletes events at the offset
    private func deleteEvent(at offsets: IndexSet) {
        let sorted = events.sorted()
        offsets.forEach { idx in
            events.remove(at: sorted.index(sorted.startIndex, offsetBy: idx))
        }
    }

    /// Adds a new event or updates an existing
    private func handleSave(_ event: Event) {
        if let idx = events.firstIndex(where: { $0.id == event.id }) {
            events[idx] = event  // edit mode — replace in place
        } else {
            events.append(event)   // add mode — append, list re-sorts on render
        }
    }
}

#Preview {
    EventsScreen(events: [])
}

#Preview {
    EventsScreen(events: Event.sampleEvents)
}
