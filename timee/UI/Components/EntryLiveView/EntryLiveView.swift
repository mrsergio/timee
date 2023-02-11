//
//  EntryLiveView.swift
//  timee
//
//  Created by Sergii Simakhin on 2/11/23.
//

import SwiftUI

enum EntryState {
    case idle, active
}

struct EntryLiveView: View {
    private let accentColor = Color.LightYellow
    
    @State var entry: String
    @State var state: EntryState
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Capsule()
                    .strokeBorder(accentColor.opacity(0.25), lineWidth: 2)
                
                TextField(
                    "",
                    text: $entry,
                    prompt: Text("I'm working on...")
                        .foregroundColor(accentColor.opacity(0.75))
                )
                .foregroundColor(accentColor)
                .padding([.leading, .trailing], 16)
            }
            .padding([.top, .bottom], 3)
            
            Button {
                // action handler
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
                return Color.yellow
            case .active:
                return Color.red
        }
    }
}

struct EntryLiveView_Previews: PreviewProvider {
    static var previews: some View {
        EntryLiveView(entry: "", state: .idle)
            .frame(width: 300, height: 44)
            .background(Color.DarkPurple)
            .previewDisplayName("Idle")
        
        EntryLiveView(entry: "Patient #5", state: .active)
            .frame(width: 300, height: 44)
            .background(Color.DarkPurple)
            .previewDisplayName("Active")
    }
}
