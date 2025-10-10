class AppConfig {
  // Geofence Configuration
  static const double geofenceRadius = 100.0; // meters
  static const double defaultLatitude = 37.7749; // Default office location
  static const double defaultLongitude = -122.4194;

  // Face Recognition Configuration
  static const double faceMatchThreshold = 0.8;
  static const int maxFaceRetries = 3;

  // Working Hours Configuration
  static const String workStartTime = "09:00";
  static const String workEndTime = "18:00";
  static const int minWorkHours = 8;

  // Admin Configuration
  static const String defaultAdminEmail = "admin@empatt.com";
  static const String defaultAdminPassword = "admin123";

  // Date Formats
  static const String dateFormat = "dd/MM/yyyy";
  static const String timeFormat = "HH:mm";
  static const String dateTimeFormat = "dd/MM/yyyy HH:mm";

  // Firebase Collections
  static const String usersCollection = "users";
  static const String attendanceCollection = "attendance";
  static const String leaveCollection = "leave_requests";
  static const String faceDataCollection = "face_data";
  static const String settingsCollection = "settings";

  // Storage Paths
  static const String faceImagesPath = "face_images/";
  static const String reportsPath = "reports/";

  // App Info
  static const String appName = "EmpAtt";
  static const String appVersion = "1.0.0";
}
