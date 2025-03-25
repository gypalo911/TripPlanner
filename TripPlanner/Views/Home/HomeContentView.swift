//
//  ContentView.swift
//  TripPlanner
//
//  Created by Petro Hupalo on 19/03/2025.
//

import SwiftUI
import MapKit

extension Home {
    /// View for Home
    struct ContentView: View {
        @ObservedObject var viewModel: ViewModel
        
        var body: some View {
            VStack(spacing: 16) {
                TitleView()
                CitySelectionView(viewModel: viewModel)
                
                searchResult
                
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .sheet(
                isPresented: $viewModel.isOriginSearchActive,
                content: { originSearchSheet }
            )
            .sheet(
                isPresented: $viewModel.isDestinationSearchActive,
                content: { destinationSearchSheet }
            )
            .task {
                await viewModel.loadConnections()
            }
        }
        
        // MARK: - View Components
        
        @ViewBuilder
        private var searchResult: some View {
            switch viewModel.state {
            case .loaded(let route):
                RouteInfoView(route: route)
                MapView(route: route)
            case .error(let message):
                ErrorView(message: message)
            case .loading(let title, let subtitle):
                LoadingView(title: title, subTitle: subtitle)
            case .initial:
                EmptyView()
            }
        }
        
        private var originSearchSheet: some View {
            CitySearchView(
                cities: viewModel.filteredOriginCities,
                onCitySelected: { city in
                    viewModel.originCity = city
                    viewModel.isOriginSearchActive = false
                },
                onSearch: viewModel.filterOriginCities(with:)
            )
            .presentationDetents([.medium, .large])
        }
        
        private var destinationSearchSheet: some View {
            CitySearchView(
                cities: viewModel.filteredDestinationCities,
                onCitySelected: { city in
                    viewModel.destinationCity = city
                    viewModel.isDestinationSearchActive = false
                },
                onSearch: viewModel.filterDestinationCities(with:)
            )
            .presentationDetents([.medium, .large])
        }
    }
}

// MARK: - Subviews

extension Home {
    struct TitleView: View {
        var body: some View {
            Text("Trip Planner")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
    
    struct CitySelectionView: View {
        @ObservedObject var viewModel: ViewModel
        
        var body: some View {
            VStack(spacing: 16) {
                CityField(
                    text: $viewModel.originCity,
                    placeholder: "Select Origin City",
                    systemImage: "airplane.departure",
                    action: {
                        viewModel.filterOriginCities(with: "")
                        viewModel.isOriginSearchActive = true
                    }
                )
                
                CityField(
                    text: $viewModel.destinationCity,
                    placeholder: "Select Destination City",
                    systemImage: "airplane.arrival",
                    action: {
                        viewModel.filterDestinationCities(with: "")
                        viewModel.isDestinationSearchActive = true
                    }
                )
                
                findRouteButton
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
        }
        
        private var findRouteButton: some View {
            Button(action: viewModel.findRoute) {
                Text("Find Route")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.isSearchButtonEnabled ? Color.blue : Color.gray)
                    .cornerRadius(10)
            }
            .disabled(!viewModel.isSearchButtonEnabled)
        }
    }
    
    struct CityField: View {
        @Binding var text: String

        let placeholder: String
        let systemImage: String
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack {
                    Image(systemName: systemImage)
                        .foregroundColor(.gray)
                    
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(.gray)
                    } else {
                        Text(text)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
            }
        }
    }
    
    struct RouteInfoView: View {
        let route: ResultRouteModel
        
        var body: some View {
            VStack(spacing: 8) {
                Text("Total Price: \(route.formattedPrice)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Route: \(route.formattedPath)")
                    .font(.body)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
        }
    }
    
    struct MapView: View {
        let route: ResultRouteModel
        
        var body: some View {
            MapViewRepresentable(route: route)
                .frame(height: 300)
                .cornerRadius(10)
        }
    }
    
    struct ErrorView: View {
        let message: String
        
        var body: some View {
            Text(message)
                .foregroundColor(.red)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
        }
    }
    
    struct LoadingView: View {
        let title: String
        let subTitle: String?
        
        var body: some View {
            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.5)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let subTitle {
                    Text(subTitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
        }
    }
}

#Preview {
    Home.build()
}
