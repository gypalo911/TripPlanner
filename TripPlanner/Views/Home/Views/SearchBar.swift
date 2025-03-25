//
//  SearchBar.swift
//  TripPlanner
//
//  Created by Petro Hupalo on 23/03/2025.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    let onSearchChanged: (String) -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search", text: $text)
                .onChange(of: text, initial: false) { oldValue, newValue in
                    onSearchChanged(newValue)
                }
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onSearchChanged("")
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
