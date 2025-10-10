import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math' show cos, sqrt, asin;
import '../config/app_config.dart';

class LocationService {
  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permission
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  // Get current location
  Future<Position> getCurrentLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled. Please enable location services.';
    }

    // Check permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permission denied. Please grant location permission.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied. Please enable them in settings.';
    }

    // Get current position
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      return position;
    } catch (e) {
      throw 'Failed to get current location: $e';
    }
  }

  // Get address from coordinates
  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''} ${place.postalCode ?? ''}'
            .trim();
      }
      return 'Unknown location';
    } catch (e) {
      return 'Could not determine address';
    }
  }

  // Calculate distance between two coordinates (Haversine formula)
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // Earth's radius in meters

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2));

    double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * (3.141592653589793 / 180);
  }

  double sin(double radians) {
    return radians - (radians * radians * radians) / 6 +
        (radians * radians * radians * radians * radians) / 120;
  }

  // Check if current location is within geofence
  Future<bool> isWithinGeofence({
    double? officeLatitude,
    double? officeLongitude,
    double? radiusInMeters,
  }) async {
    try {
      Position currentPosition = await getCurrentLocation();

      double distance = calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        officeLatitude ?? AppConfig.defaultLatitude,
        officeLongitude ?? AppConfig.defaultLongitude,
      );

      return distance <= (radiusInMeters ?? AppConfig.geofenceRadius);
    } catch (e) {
      throw 'Failed to verify location: $e';
    }
  }

  // Get location permission status message
  String getPermissionStatusMessage(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return 'Location permission is denied. Please grant permission to mark attendance.';
      case LocationPermission.deniedForever:
        return 'Location permission is permanently denied. Please enable it in app settings.';
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return 'Location permission granted.';
      default:
        return 'Unknown permission status.';
    }
  }

  // Get distance from office in meters
  Future<double> getDistanceFromOffice({
    double? officeLatitude,
    double? officeLongitude,
  }) async {
    try {
      Position currentPosition = await getCurrentLocation();

      return calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        officeLatitude ?? AppConfig.defaultLatitude,
        officeLongitude ?? AppConfig.defaultLongitude,
      );
    } catch (e) {
      throw 'Failed to calculate distance: $e';
    }
  }

  // Stream of position updates
  Stream<Position> getPositionStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  // Format distance for display
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(2)} km';
    }
  }
}
