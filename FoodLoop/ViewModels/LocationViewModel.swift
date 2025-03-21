class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
@Published var location: CLLocation?
private var locationManager = CLLocationManager()
override init() {
super.init()
locationManager.delegate = self
}
func requestLocation() {
locationManager.requestWhenInUseAuthorization()
locationManager.startUpdatingLocation()
}
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
if let location = locations.last {
self.location = location
}
}
}