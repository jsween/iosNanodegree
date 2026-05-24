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
        HStack {
            Image(systemName: event.iconName)
                .foregroundStyle(event.textColor)
                .font(.title)
                .frame(width: 48, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.secondary.opacity(0.1))
                )

            VStack(alignment: .leading) {
                Text(event.title)
                    .font(.title2)
                    .foregroundStyle(event.textColor)

                Text(relativeDate)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 16)
            }
            Spacer()
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

#Preview(traits: .sizeThatFitsLayout) {
    EventRow(event: Event.event1)
        .padding()
}
