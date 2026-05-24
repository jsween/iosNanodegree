//
//  EventRow.swift
//  UntilThen
//
//  Created by Jonathan Sweeney on 5/23/26.
//

import SwiftUI
internal import Combine

/// A list row that displays an event's title and a live countdown to (or since) its datetime
struct EventRow: View {

    // MARK: - Properties

    /// Formatted relative date string (e.g. in 3 weeks, 2 days ago)
    @State private var relativeDate: String = ""

    /// The event shown in view
    let event: Event

    /// Fires every second to keep the relative date string up to date
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // MARK: - Formatter

    /// Formats a date relative to the current moment.
    private let formatter: RelativeDateTimeFormatter = {
        let rdtf = RelativeDateTimeFormatter()
        rdtf.unitsStyle = .full  // e.g. "2 hours ago" vs "2 hr. ago"
        return rdtf
    }()

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event.title)
                .font(.headline)
                .foregroundStyle(event.textColor)

            Text(relativeDate)
                .font(.subheadline)
                .foregroundStyle(.black)
        }
        .onAppear(perform: updateRelativeDate)
        .onReceive(timer) { _ in
            updateRelativeDate()
        }
    }

    // MARK: - Helpers

    /// Updates `relativeDate` by formatting the event's date relate to now
    private func updateRelativeDate() {
        relativeDate = formatter.localizedString(for: event.date, relativeTo: .now)
    }
}

#Preview {
    EventRow(event: Event.event1)
}
