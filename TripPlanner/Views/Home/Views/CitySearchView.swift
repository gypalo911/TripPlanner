//
//  CitySearchView.swift
//  TripPlanner
//
//  Created by Petro Hupalo on 23/03/2025.
//

import SwiftUI

struct CitySearchView: View {
    let cities: [String]
    let onCitySelected: (String) -> Void
    let onSearch: (String) -> Void
    
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText, onSearchChanged: onSearch)
                .padding(.horizontal)
                .padding(.top, 20)
            
            List(cities, id: \.self) { city in
                Button(action: { onCitySelected(city) }) {
                    Text(city)
                }
            }
        }
    }
}
