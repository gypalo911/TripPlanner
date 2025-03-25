//
//  Home.swift
//  TripPlanner
//
//  Created by Petro Hupalo on 23/03/2025.
//

import SwiftUI

struct Home {
    /// Entry point for the Home
    static func build() -> some View {
        let configuration = Configuration()
        let viewModel = Home.ViewModel(
            networkService: configuration.networkService,
            routeFinder: configuration.routeFinder
        )

        return Home.ContentView(viewModel: viewModel)
    }
}
