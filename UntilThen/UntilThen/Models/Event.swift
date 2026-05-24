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
struct Event: Identifiable, Comparable, Hashable {

    /// A unique identifier for the event, used by SwiftUI to track list rows.
    let id: UUID

    /// The name of the event, displayed in each row and editable via `EventForm`.
    var title: String

    /// The date and time of the event, used for countdown and sorting.
    var date: Date

    /// The color used to render the event title in `EventRow`.
    var textColor: Color

    /// The icon for the event
    var iconName: String

    init(id: UUID = UUID(), title: String, date: Date, textColor: Color, iconName: String = "calendar") {
        self.id = id
        self.title = title
        self.date = date
        self.textColor = textColor
        self.iconName = iconName
    }

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
    static let event1 = Event(title: "Event 1", date: .now.addingTimeInterval(500), textColor: .red, iconName: "star")
    static let event2 = Event(title: "Event 2", date: .now.addingTimeInterval(1_000), textColor: .blue, iconName: "star.fill")
    static let event3 = Event(title: "Event 3", date: .now.addingTimeInterval(2_000_000), textColor: .yellow, iconName: "heart.fill")
    static let event4 = Event(title: "Event 4", date: .now.addingTimeInterval(100_000_000), textColor: .green)

    static let sampleEvents: [Event] = [event1, event2, event3, event4]
}
#endif
