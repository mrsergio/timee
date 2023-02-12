//
//  EntryLiveView.swift
//  timee
//
//  Created by Sergii Simakhin on 2/11/23.
//

import SwiftUI

struct EntryLiveView: View {
    private let accentColor = Color.LightYellow
    private let placeholder: String = "I'm working on..."
    
    @State private var title: String = ""
    
    /// View changes according to the entry state
    enum EntryState {
        case idle, active
    }
    let state: EntryState
    
    /**
     String = current title (it could be edited before and while timer is on)
    */
    var onStart: (String) -> Void
    var onStop: (String) -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            /* Text input wrapped with a capsule stroke */
            ZStack {
                Capsule()
                    .strokeBorder(
                        accentColor.opacity(0.25),
                        lineWidth: 2
                    )
                
                TextField(
                    "",
                    text: $title,
                    prompt: Text(placeholder)
                        .foregroundColor(accentColor.opacity(0.75))
                )
                .onSubmit {
                    // Start an entry timer when entry was in idle state; otherwise update the title only
                    if state == .idle {
                        onSubmit()
                    }
                }
                .foregroundColor(accentColor)
                .padding([.leading, .trailing], 16)
            }
            .padding([.top, .bottom], 3)
            
            /* Play / pause button */
            Button {
                onSubmit()
            } label: {
                Image(systemName: buttonIconSystemName)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundColor(buttonColor)
                    .background(buttonColor.opacity(0.15))
                    .clipShape(Circle())
            }
        }
    }
    
    private func onSubmit() {
        switch state {
            case .idle:
                // Starting time tracking session
                onStart(title)
                
            case .active:
                // Finishing time tracking session
                onStop(title)
        }
    }
    
    private var buttonIconSystemName: String {
        switch state {
            case .idle:
                return "play.circle"
            case .active:
                return "stop.circle"
                
        }
    }
    
    private var buttonColor: Color {
        switch state {
            case .idle:
                return Color.LightYellow
            case .active:
                return Color.Orange
        }
    }
}

struct EntryLiveView_Previews: PreviewProvider {
    static var previews: some View {
        EntryLiveView(
            state: .idle,
            onStart: { _ in },
            onStop: { _ in }
        )
        .frame(width: 300, height: 44)
        .background(Color.DarkPurple)
        .previewDisplayName("Idle")
        
        EntryLiveView(
            state: .active,
            onStart: { _ in },
            onStop: { _ in }
        )
        .frame(width: 300, height: 44)
        .background(Color.DarkPurple)
        .previewDisplayName("Active")
    }
}
