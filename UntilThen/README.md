# Until Then

A simple iOS countdown app that helps you track upcoming events.

## Features

### Event Management
- **Create & Edit Events** - Add events with custom titles, dates, colors, and SF Symbol icons
- **Smart Date Picker** - Select future dates and times with 15-minute interval rounding
- **Live Countdowns** - Real-time relative time updates (e.g., "in 3 days", "in 2 hours")
- **Persistent Storage** - Events automatically save using SwiftData

### Visual Feedback
- **Pulsing Animations** - Events pulse when they're within 100 seconds of occurring
- **Symbol Effects** - Bouncing and pulsing animations guide user interactions
- **Custom Colors** - Choose any color for your event titles
- **SF Symbols** - Pick from hundreds of icons to represent your events
- **Haptic Feedback** - Success haptics when saving events

### Past Events Toggle
- **Smart Filtering** - Hide or show past events with a single tap
- **Empty States** - Contextual messages when no events exist or all are in the past
- **TipKit Integration** - Helpful tip explains the past events toggle feature

### User Experience
- **Sorted List** - Events automatically sort by date (soonest first)
- **Swipe to Delete** - Remove events with a swipe gesture
- **Form Validation** - Save button disabled until event has a title
- **Empty State Guidance** - Clear instructions for adding your first event

## Technologies Used

- **SwiftUI** - Modern declarative UI framework
- **SwiftData** - Persistent storage and data management
- **TipKit** - Contextual user guidance
- **Combine** - Real-time countdown updates
- **UIKit Integration** - Custom date pickers and haptic feedback

## Architecture

### Models
- `Event` - SwiftData model for persisting event data with RGBA color storage
- `EventFormMode` - Enum for add/edit navigation modes

### Views
- `EventsScreen` - Main list view with filtering and navigation
- `EventForm` - Add/edit form with validation
- `EventRow` - Individual event row with live countdown and pulse animation
- `SymbolPicker` - SF Symbol selection interface

### Features
- **Live Updates** - Timer-based countdown refreshing every second
- **Smart Color Storage** - RGBA components stored separately for SwiftData compatibility
- **Computed Properties** - Efficient filtering and sorting
- **Preview Support** - Multiple previews with in-memory containers

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 6.0+

### Future Enhancements
- [ ] Widget support for upcoming events
- [ ] Notifications when events occur
- [ ] Event categories or tags
- [ ] Recurring events
- [ ] Event photos or attachments

## License

Created by Jonathan Sweeney on 5/23/26.

---

**Until Then** - Count down to what matters ⏰
