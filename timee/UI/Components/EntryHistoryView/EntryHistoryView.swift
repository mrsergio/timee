//
//  EntryHistoryView.swift
//  timee
//
//  Created by Sergii Simakhin on 2/11/23.
//

import SwiftUI

struct EntryHistoryView: View {
    @State var entry: String
    @State var duration: String
    @State var when: String
    
    var body: some View {
        HStack() {
            Text(entry)
                .font(.headline)
                .foregroundColor(Color.DarkPurple)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(when)
                    .font(.footnote)
                    .foregroundColor(Color.LightPurple)
                
                Text(duration)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.Orange)
            }
        }
    }
}

struct EntryHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        EntryHistoryView(
            entry: "Patient #5",
            duration: "0:00:34",
            when: "today"
        )
        .frame(width: 300, height: 44)
        .background(Color.gray.opacity(0.1))
        .previewDisplayName("Idle")
    }
}
