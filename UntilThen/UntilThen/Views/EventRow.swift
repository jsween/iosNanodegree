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

    // MARK: - State

    /// Formatted relative date string (e.g. in 3 weeks, 2 days ago)
    @State private var relativeDate: String = ""
    
    /// Tracks whether animation should be active
    @State private var isAnimating: Bool = false

    @State private var shouldDim: Bool = false

    // MARK: - Properties

    /// The event shown in view
    let event: Event

    /// Is the event about to start (within 10 seconds and still in the future)
    private var isImminent: Bool {
        let timeUntilEvent = event.date.timeIntervalSinceNow
        return timeUntilEvent > 0 && timeUntilEvent <= 11
    }

    private var isInPast: Bool {
        event.date.timeIntervalSinceNow < 0
    }

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
                .opacity(isInPast ? 0.4 : 1)
                .frame(width: 48, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.secondary.opacity(0.1))
                )
                .scaleEffect(isImminent && isAnimating ? 1.3 : 1.0)
                .animation(
                    isAnimating 
                    ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                    : .easeInOut(duration: 0.3),
                    value: isAnimating
                )

            VStack(alignment: .leading) {
                Text(event.title)
                    .font(.title2)
                    .foregroundStyle(event.textColor)
                    .opacity(isInPast ? 0.4 : 1)

                Text(relativeDate)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 16)
            }
            Spacer()
        }
        .onAppear {
            updateRelativeDate()
            // Initialize animation state on appear
            isAnimating = isImminent
            shouldDim = isInPast
        }
        .onReceive(timer) { _ in
            updateRelativeDate()
            // Update animation based on current imminence
            isAnimating = isImminent
            shouldDim = isInPast
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

#Preview(traits: .sizeThatFitsLayout) {
    EventRow(event: Event.event0)
        .padding()
}
