//
//  EventTests.swift
//  UntilThenTests
//
//  Created by Jonathan Sweeney on 5/21/26.
//

import Testing
import SwiftUI
@testable import UntilThen

@Suite("Event Tests") @MainActor
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
        
        // Compare color by checking it's approximately red
        let uiColor = UIColor(event.textColor)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Red should be high, green and blue should be low
        #expect(red > 0.9)
        #expect(green < 0.3)
        #expect(blue < 0.3)
        #expect(alpha > 0.9)
    }
    
    @Test("Event color round-trips correctly")
    func colorRoundTrip() {
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
        
        for color in colors {
            let event = Event(title: "Test", date: referenceDate, textColor: color)
            
            // Get the stored color back
            let storedColor = event.textColor
            
            // Convert both to UIColor for comparison
            let originalUIColor = UIColor(color)
            let storedUIColor = UIColor(storedColor)
            
            var origR: CGFloat = 0, origG: CGFloat = 0, origB: CGFloat = 0, origA: CGFloat = 0
            var storeR: CGFloat = 0, storeG: CGFloat = 0, storeB: CGFloat = 0, storeA: CGFloat = 0
            
            originalUIColor.getRed(&origR, green: &origG, blue: &origB, alpha: &origA)
            storedUIColor.getRed(&storeR, green: &storeG, blue: &storeB, alpha: &storeA)
            
            // Check each component is approximately equal (within 0.01 tolerance)
            #expect(abs(origR - storeR) < 0.01)
            #expect(abs(origG - storeG) < 0.01)
            #expect(abs(origB - storeB) < 0.01)
            #expect(abs(origA - storeA) < 0.01)
        }
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
    
    // MARK: - Icon Tests
    
    @Test("Event uses default icon when not specified")
    func defaultIcon() {
        let event = Event(title: "Test", date: referenceDate, textColor: .blue)
        #expect(event.iconName == "calendar")
    }
    
    @Test("Event stores custom icon correctly")
    func customIcon() {
        let event = Event(title: "Test", date: referenceDate, textColor: .blue, iconName: "star.fill")
        #expect(event.iconName == "star.fill")
    }
    
    // MARK: - ID Tests
    
    @Test("Each event has a unique ID")
    func uniqueIDs() {
        let event1 = Event(title: "Event 1", date: referenceDate, textColor: .red)
        let event2 = Event(title: "Event 2", date: referenceDate, textColor: .blue)
        
        #expect(event1.id != event2.id)
    }
    
    @Test("Event ID can be specified on initialization")
    func customID() {
        let customID = UUID()
        let event = Event(id: customID, title: "Test", date: referenceDate, textColor: .green)
        
        #expect(event.id == customID)
    }
    
    // MARK: - Mutability Tests
    
    @Test("Event properties can be modified")
    func eventMutability() {
        let event = Event(title: "Original", date: referenceDate, textColor: .red)
        
        event.title = "Modified"
        event.textColor = .blue
        event.iconName = "heart.fill"
        
        #expect(event.title == "Modified")
        #expect(event.iconName == "heart.fill")
        
        // Check blue color
        let uiColor = UIColor(event.textColor)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #expect(blue > 0.9)
        #expect(red < 0.3)
    }
    
    // MARK: - Edge Cases
    
    @Test("Events with identical dates are equal in comparison")
    func identicalDatesAreEqual() {
        let event1 = Event(title: "First", date: referenceDate, textColor: .red)
        let event2 = Event(title: "Second", date: referenceDate, textColor: .blue)
        
        // Neither should be less than the other
        #expect(!(event1 < event2))
        #expect(!(event2 < event1))
    }
    
    @Test("Event handles very distant future dates")
    func distantFutureDates() {
        let farFuture = referenceDate.addingTimeInterval(365 * 24 * 60 * 60 * 100) // 100 years
        let event = Event(title: "Far Future", date: farFuture, textColor: .purple)
        
        #expect(event.date == farFuture)
    }
    
    @Test("Event handles very distant past dates")
    func distantPastDates() {
        let farPast = referenceDate.addingTimeInterval(-365 * 24 * 60 * 60 * 100) // 100 years ago
        let event = Event(title: "Far Past", date: farPast, textColor: .orange)
        
        #expect(event.date == farPast)
    }
    
    @Test("Event handles empty title")
    func emptyTitle() {
        let event = Event(title: "", date: referenceDate, textColor: .gray)
        #expect(event.title == "")
    }
    
    @Test("Event handles very long title")
    func longTitle() {
        let longTitle = String(repeating: "A", count: 1000)
        let event = Event(title: longTitle, date: referenceDate, textColor: .cyan)
        #expect(event.title == longTitle)
        #expect(event.title.count == 1000)
    }
}

// MARK: - Date Extension Tests

@Suite("Date Extension Tests")
struct DateExtensionTests {
    
    @Test("nextQuarterHour rounds up to next 15-minute interval")
    func nextQuarterHourRoundsUp() {
        // Create a date at 10:32
        let calendar = Calendar.current
        let components = DateComponents(year: 2026, month: 5, day: 28, hour: 10, minute: 32)
        let testDate = calendar.date(from: components)!
        
        let rounded = testDate.nextQuarterHour
        let roundedComponents = calendar.dateComponents([.hour, .minute], from: rounded)
        
        #expect(roundedComponents.hour == 10)
        #expect(roundedComponents.minute == 45)
    }
}

// MARK: - EventFormMode Tests

@Suite("EventFormMode Tests") @MainActor
struct EventFormModeTests {
    
    let referenceDate = Date()
    
    @Test("Add mode equals itself")
    func addModeEquality() {
        let mode1 = EventFormMode.add
        let mode2 = EventFormMode.add
        
        #expect(mode1 == mode2)
    }
    
    @Test("Edit mode equals itself when same event ID")
    func editModeEqualityWithSameID() {
        let event = Event(title: "Test", date: referenceDate, textColor: .red)
        let mode1 = EventFormMode.edit(event)
        let mode2 = EventFormMode.edit(event)
        
        #expect(mode1 == mode2)
    }
    
    @Test("Edit mode not equal when different event IDs")
    func editModeInequalityWithDifferentIDs() {
        let event1 = Event(title: "Test 1", date: referenceDate, textColor: .red)
        let event2 = Event(title: "Test 2", date: referenceDate, textColor: .blue)
        
        let mode1 = EventFormMode.edit(event1)
        let mode2 = EventFormMode.edit(event2)
        
        #expect(mode1 != mode2)
    }
    
    @Test("Add mode not equal to edit mode")
    func addNotEqualToEdit() {
        let event = Event(title: "Test", date: referenceDate, textColor: .red)
        let addMode = EventFormMode.add
        let editMode = EventFormMode.edit(event)
        
        #expect(addMode != editMode)
    }
    
    @Test("EventFormMode is hashable")
    func eventFormModeHashable() {
        let event = Event(title: "Test", date: referenceDate, textColor: .red)
        let addMode = EventFormMode.add
        let editMode = EventFormMode.edit(event)
        
        var set = Set<EventFormMode>()
        set.insert(addMode)
        set.insert(editMode)
        
        #expect(set.count == 2)
        #expect(set.contains(addMode))
        #expect(set.contains(editMode))
    }
}
