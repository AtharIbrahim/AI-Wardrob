import 'package:geolocator/geolocator.dart';

class LocationService {
  static const double _defaultLatitude = 40.7128; // New York City default
  static const double _defaultLongitude = -74.0060;

  /// Get current user location
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return null;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied.');
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Get default location (fallback)
  Position getDefaultLocation() {
    return Position(
      latitude: _defaultLatitude,
      longitude: _defaultLongitude,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
  }

  /// Check if location permissions are granted
  Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  /// Request location permissions
  Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      return permission == LocationPermission.always || 
             permission == LocationPermission.whileInUse;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  /// Get location from coordinates with fallback
  Future<Position> getLocationOrDefault() async {
    Position? currentLocation = await getCurrentLocation();
    return currentLocation ?? getDefaultLocation();
  }

  /// Check if location services are available
  Future<bool> isLocationServiceAvailable() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      bool hasPermission = await hasLocationPermission();
      return serviceEnabled && hasPermission;
    } catch (e) {
      print('Error checking location service availability: $e');
      return false;
    }
  }

  /// Get city name from coordinates (requires reverse geocoding - can be added later)
  Future<String?> getCityFromCoordinates(double latitude, double longitude) async {
    // This would require a geocoding service like Google Geocoding API
    // For now, return null and let weather service handle coordinates directly
    return null;
  }
}
