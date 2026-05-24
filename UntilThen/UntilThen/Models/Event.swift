//
//  Event.swift
//  UntilThen
//
//  Created by Jonathan Sweeney on 5/21/26.
//

import SwiftUI

/// Represents a single user-defined event with a title, date, and display color.
///
/// Events conform to `Identifiable` so SwiftUI's `List` can track each row,
/// and to `Comparable` so an array of events can be sorted by date using `.sorted()`.
struct Event: Identifiable, Comparable {

    /// A unique identifier for the event, used by SwiftUI to track list rows.
    let id: UUID = UUID()

    /// The name of the event, displayed in each row and editable via `EventForm`.
    var title: String

    /// The date and time of the event, used for countdown and sorting.
    var date: Date

    /// The color used to render the event title in `EventRow`.
    var textColor: Color

    /// Returns `true` if the left event occurs sooner than the right event.
    ///
    /// This enables `.sorted()` on an array of events to order them by date,
    /// with the soonest event appearing first.
    static func < (lhs: Event, rhs: Event) -> Bool {
        lhs.date < rhs.date
    }
}

#if DEBUG
extension Event {
    static let event1 = Event(title: "Event 1", date: .now.addingTimeInterval(500), textColor: .red)
    static let event2 = Event(title: "Event 2", date: .now.addingTimeInterval(1_000), textColor: .blue)
    static let event3 = Event(title: "Event 3", date: .now.addingTimeInterval(2_000), textColor: .yellow)

    static let sampleEvents: [Event] = [event1, event2, event3]
}
#endif
