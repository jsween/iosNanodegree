//
//  EventsScreen.swift
//  UntilThen
//
//  Created by Jonathan Sweeney on 5/23/26.
//

import SwiftUI

/// Displays a sorted, swipeable list of events and handles navigation to EventForm
struct EventsScreen: View {

    // MARK: State

    /// The master list of events, sorted on display
    @State var events: [Event] = []

    // MARK: Body

    var body: some View {
        NavigationStack {
            List {
                ForEach(events) { event in
                    NavigationLink(value: EventFormMode.edit(event)) {
                        EventRow(event: event)
                    }
                }
                .onDelete(perform: deleteEvent)
            }
            .navigationTitle(Text("Until Then"))
            .navigationDestination(for: EventFormMode.self) { mode in
                EventForm(mode: mode, onSave: handleSave)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: EventFormMode.add) {
                        Image(systemName: "plus")
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
    EventsScreen(events: Event.sampleEvents)
}
