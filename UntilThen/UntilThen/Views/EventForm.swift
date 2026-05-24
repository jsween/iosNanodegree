//
//  EventForm.swift
//  UntilThen
//
//  Created by Jonathan Sweeney on 5/23/26.
//

import SwiftUI

/// A form for creating a new event or editing
struct EventForm: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Properties

    let mode: EventFormMode

    let onSave: (Event) -> Void

    // MARK: - State

    /// Local editable copies of the event's fields, changes based on mode
    @State private var title: String
    @State private var date: Date
    @State private var textColor: Color

    /// The event being edited, if in edit mode
    private var existingEvent: Event? {
        if case .edit(let event) = mode { return event }
        return nil
    }

    // MARK: - Init

    init(mode: EventFormMode, onSave: @escaping (Event) -> Void) {
        self.mode = mode
        self.onSave = onSave

        // Seed local state from the existing event, or use defaults
        if case .edit(let event) = mode {
            _title = State(initialValue: event.title)
            _date = State(initialValue: event.date)
            _textColor = State(initialValue: event.textColor)
        } else {
            _title = State(initialValue: "")
            _date = State(initialValue: .now)
            _textColor = State(initialValue: .primary)
        }
    }

    var body: some View {
        Form {
            Section {
                TextField("Event Title", text: $title)

                DatePicker("Date",
                           selection: $date,
                           displayedComponents: [.date, .hourAndMinute]
                )
                ColorPicker("TitleColor", selection: $textColor)
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    handleSave()
                }
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    // Generate title depending on mode (add or edit)
    private var navigationTitle: String {
        switch mode {
        case .add:
            return "Add Event"
        case .edit(let event):
            return "Edit \(event.title)"
        }
    }

    // Builds the event and passes to parent, then dismisses
    private func handleSave() {
        let event = Event(id: existingEvent?.id ?? UUID(), title: title.trimmingCharacters(in: .whitespacesAndNewlines), date: date, textColor: textColor)
        onSave(event)
        dismiss()
    }
}

#Preview("Add Mode") {
    NavigationStack {
        EventForm(mode: .add, onSave: { _ in })
    }
}

#Preview("Edit Mode") {
    NavigationStack {
        EventForm(mode: .edit(Event.event1), onSave: { _ in })
    }
}
