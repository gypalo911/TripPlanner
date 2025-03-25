//
//  HomeViewState.swift
//  TripPlannerTests
//
//  Created by Petro Hupalo on 23/03/2025.
//

import Foundation
@testable import TripPlanner

extension Home.ViewState: Equatable {
    public static func == (lhs: Home.ViewState, rhs: Home.ViewState) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial):
            return true
        case (.loading, .loading):
            return true
        case (.loaded(let lhsViewModel), .loaded(let rhsViewModel)):
            return lhsViewModel.totalPrice == rhsViewModel.totalPrice &&
            lhsViewModel.formattedPath == rhsViewModel.formattedPath &&
            lhsViewModel.routeCoordinates.count == rhsViewModel.routeCoordinates.count
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}
