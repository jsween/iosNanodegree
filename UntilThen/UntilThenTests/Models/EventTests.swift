//
//  EventTests.swift
//  UntilThenTests
//
//  Created by Jonathan Sweeney on 5/21/26.
//

import Testing
import SwiftUI
@testable import UntilThen

@Suite("Event Tests")
struct EventTests {

    // MARK: - Setup

    /// A fixed reference date used across tests to keep results predictable.
    let referenceDate = Date()

    // MARK: - Initialization

    @Test("Event stores all properties correctly on initialization")
    func eventInitialization() {
        let title = "Disneyland Trip"
        let date = referenceDate
        let color = Color.red

        let event = Event(title: title, date: date, textColor: color)

        #expect(event.title == title)
        #expect(event.date == date)
        #expect(event.textColor == color)
    }

    // MARK: Comparable

    @Test("Earlier event is less than a later event")
    func earlierEventIsLessThanLaterEvent() {
        let earlier = Event(
            title: "First",
            date: referenceDate,
            textColor: .blue
        )

        let later = Event(
            title: "Second",
            date: referenceDate.addingTimeInterval(3600),
            textColor: .blue

        )

        #expect(earlier < later)
        #expect(!(later < earlier))
    }

    // MARK: - Sorting

    @Test("sorted() returns events with soonest date first")
    func sortedReturnsSoonestEventFirst() {
        let soonest = Event(
            title: "Soonest",
            date: referenceDate,
            textColor: .green
        )
        let middle = Event(
            title: "Middle",
            date: referenceDate.addingTimeInterval(86400), // 1 day later
            textColor: .yellow
        )
        let latest = Event(
            title: "Latest",
            date: referenceDate.addingTimeInterval(604800), // 1 week later
            textColor: .red
        )

        // Intentionally shuffled
        let sorted = [latest, soonest, middle].sorted()

        #expect(sorted[0].title == "Soonest")
        #expect(sorted[1].title == "Middle")
        #expect(sorted[2].title == "Latest")
    }

    @Test("sorted() places past events before future events")
    func sortedHandlesMixOfPastAndFutureEvents() {
        let pastEvent = Event(
            title: "Past",
            date: referenceDate.addingTimeInterval(-86400), // 1 day ago
            textColor: .gray
        )
        let futureEvent = Event(
            title: "Future",
            date: referenceDate.addingTimeInterval(86400), // 1 day from now
            textColor: .blue
        )

        let sorted = [futureEvent, pastEvent].sorted()

        #expect(sorted[0].title == "Past")
        #expect(sorted[1].title == "Future")
    }
}
