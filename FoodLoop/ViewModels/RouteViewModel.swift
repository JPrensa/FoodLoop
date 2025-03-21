import MapKit
@MainActor
class RouteViewModel: ObservableObject {
@Published private(set) var route: MKRoute?
func calculateRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
let directionsRequest = MKDirections.Request()
directionsRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
directionsRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
directionsRequest.transportType = .automobile
Task {
let directions = MKDirections(request: directionsRequest)
let response = try? await directions.calculate()
self.route = response?.routes.first
}
}
}