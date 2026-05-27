//
//  PastEventsTip.swift
//  UntilThen
//
//  Created by Jonathan Sweeney on 5/26/26.
//

import TipKit

/// Teaches the user how to toggle past event visibility.
struct PastEventsTip: Tip {
    
    /// Parameter to track if there are past events to show/hide
    @Parameter
    static var hasPastEvents: Bool = false
    
    var title: Text {
        Text("Show or Hide Past Events")
    }

    var message: Text? {
        Text("Tap the clock to toggle visibility of events that have already passed.")
    }

    var image: Image? {
        Image(systemName: "clock.fill")
    }
    
    var rules: [Rule] {
        [
            #Rule(Self.$hasPastEvents) { $0 == true }
        ]
    }
}
