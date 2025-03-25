//
//  MapViewRepresentable.swift
//  TripPlanner
//
//  Created by Petro Hupalo on 23/03/2025.
//

import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    
    // MARK: - Properties
    
    private var coordinates: [CLLocationCoordinate2D] {
        route.routeCoordinates
    }
    
    private var cities: [String] {
        route.cities
    }
    
    let route: ResultRouteModel
    
    // MARK: - Public
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        // Add annotations for cities
        var annotations: [MKPointAnnotation] = []
        
        for (index, coordinate) in route.routeCoordinates.enumerated() {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            if index < route.cities.count {
                annotation.title = route.cities[index]
                
                if index == 0 {
                    annotation.subtitle = "Origin"
                } else if index == route.routeCoordinates.count - 1 {
                    annotation.subtitle = "Destination"
                } else {
                    annotation.subtitle = "Stopover"
                }
            }
            
            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
        
        // Add polyline
        if route.routeCoordinates.count > 1 {
            let polyline = MKPolyline(coordinates: route.routeCoordinates, count: route.routeCoordinates.count)
            mapView.addOverlay(polyline)
            
            // Zoom to show all points
            mapView.setVisibleMapRect(
                polyline.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50),
                animated: true
            )
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !annotation.isKind(of: MKUserLocation.self) else {
                return nil
            }
            
            let identifier = "CityPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            
            if annotation.subtitle == "Origin" {
                annotationView?.markerTintColor = .systemGreen
            } else if annotation.subtitle == "Destination" {
                annotationView?.markerTintColor = .systemRed
            } else {
                annotationView?.markerTintColor = .systemBlue
            }
            
            return annotationView
        }
    }
}
