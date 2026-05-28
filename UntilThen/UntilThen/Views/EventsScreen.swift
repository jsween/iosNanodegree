//
//  EventsScreen.swift
//  UntilThen
//
//  Created by Jonathan Sweeney on 5/23/26.
//

import SwiftUI
import SwiftData
import TipKit

/// Displays a sorted, swipeable list of events and handles navigation to EventForm
struct EventsScreen: View {

    // MARK: - Environment
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Event.date) private var events: [Event]

    // MARK: - State

    /// Bool to show or hide past events
    @State private var showPastEvents: Bool = true
    
    /// Tip to teach users about the past events toggle
    private let pastEventsTip = PastEventsTip()

    // MARK: - Properties
    
    private var hasPastEvents: Bool {
        events.contains { $0.date < .now }
    }
    
    private var filteredEvents: [Event] {
        return showPastEvents ? events : events.filter { $0.date > .now }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {
                if filteredEvents.isEmpty {
                    ContentUnavailableView(
                        events.isEmpty ? "No Events Yet..." : "No Upcoming Events",
                        systemImage: events.isEmpty ? "calendar.badge.plus" : "calendar.badge.clock",
                        description: Text(events.isEmpty 
                            ? "Tap the + icon to add your first event!"
                            : "All your events are in the past. Tap the clock to show them or add a new event.")
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
            .onChange(of: hasPastEvents) { _, newValue in
                PastEventsTip.hasPastEvents = newValue
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
                    .popoverTip(pastEventsTip)
                }
            }
        }
    }

    // MARK: Helpers

    /// Deletes events at the offset
    private func deleteEvent(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredEvents[index])
        }
    }

    /// Adds a new event or updates an existing
    private func handleSave(_ event: Event) {
        modelContext.insert(event)
        try? modelContext.save()
    }
}

#Preview("Empty") {
    EventsScreen()
        .modelContainer(for: Event.self, inMemory: true)
}

#Preview("With Events") {
    let container = try! ModelContainer(
        for: Event.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    Event.sampleEvents.forEach { container.mainContext.insert($0) }
    
    return EventsScreen()
        .modelContainer(container)
}
