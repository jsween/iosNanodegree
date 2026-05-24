//
//  SymbolPicker.swift
//  UntilThen
//
//  Created by Jonathan Sweeney on 5/24/26.
//

import SwiftUI

/// A grid of SF Symbols for the event icon
struct SymbolPicker: View {

    @Environment(\.dismiss) private var dismiss

    @Binding var selectedSymbol: String

    let tintColor: Color

    private let symbols = [
        "calendar",
        "birthday.cake",
        "airplane.departure",
        "beach.umbrella",
        "car.fill",
        "house.fill",
        "music.note",
        "figure.run",
        "fork.knife",
        "gift.fill",
        "heart.fill",
        "star.fill",
        "gamecontroller.fill",
        "graduationcap.fill",
        "briefcase.fill",
        "cross.case.fill",
        "camera.fill",
        "film.fill",
        "trophy.fill",
        "flag.fill",
        "moon.stars.fill",
        "sun.max.fill",
        "snowflake",
        "leaf.fill"
    ]

    private let columns = Array(repeating: GridItem(.flexible()), count: 5)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(symbols, id: \.self) { symbol in
                    Button(action: {
                        self.selectedSymbol = symbol
                        self.dismiss()
                    }) {
                        Image(systemName: symbol)
                            .font(selectedSymbol == symbol ? .largeTitle : .title)
                            .font(.title2)
                            .foregroundStyle(selectedSymbol == symbol ? .primary : .secondary)
                            .frame(width: 50, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedSymbol == symbol ? tintColor.opacity(0.15) : .clear)
                            )
                    }
                }
            }
        }
        .navigationTitle("Select an icon")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SymbolPicker(selectedSymbol: .constant("calendar"), tintColor: .blue)
    }
}
