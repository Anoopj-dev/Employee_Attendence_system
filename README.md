# EmpAtt - Employee Attendance Management System

A comprehensive Flutter-based Employee Attendance Management System with GPS tracking, face recognition, and Firebase integration.

## Features

### Employee Features
- Check-in/Check-out with GPS geofencing
- Face recognition for attendance marking
- View attendance history with calendar
- Apply for leave
- View attendance statistics
- Profile management

### Admin Features
- View all employees
- Real-time employee location tracking on Google Maps
- Generate and export reports (PDF/Excel)
- Approve/Reject leave requests
- Manual attendance entry
- Employee management (CRUD)
- Face data registration

## Technologies Used

- **Frontend**: Flutter & Dart
- **Backend**: Firebase (Auth, Firestore, Storage)
- **State Management**: Provider
- **Maps**: Google Maps Flutter
- **Face Recognition**: Google ML Kit
- **Location**: Geolocator & Geocoding
- **Reports**: PDF & Excel packages

## Firebase Setup (REQUIRED)

### Step 1: Create Firebase Project

1. Go to https://console.firebase.google.com/
2. Click "Add project"
3. Enter project name: "empatt"
4. Create project

### Step 2: Register Your App

#### Android:
1. Click Android icon
2. Package name: `com.example.empatt`
3. Download `google-services.json`
4. Place in `android/app/` directory

#### iOS:
1. Click iOS icon
2. Bundle ID: `com.example.empatt`
3. Download `GoogleService-Info.plist`
4. Place in `ios/Runner/` directory

### Step 3: Enable Firebase Services

1. **Authentication** → Enable Email/Password
2. **Firestore Database** → Create database (test mode)
3. **Storage** → Get started (test mode)

### Step 4: Configure Android

Edit `android/build.gradle`:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.2'
    }
}
```

Edit `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

### Step 5: Add Permissions

`android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

## Installation

```bash
flutter pub get
flutter run
```

## Default Admin Account

After first run, create admin manually in Firestore:
1. Register as normal user
2. In Firestore, change user's `role` field from `employee` to `admin`

## Configuration

Edit `lib/config/app_config.dart`:
```dart
static const double defaultLatitude = YOUR_OFFICE_LAT;
static const double defaultLongitude = YOUR_OFFICE_LONG;
static const double geofenceRadius = 100.0; // meters
```

## Project Status

✅ Core architecture implemented
✅ Models and services created
✅ Firebase integration ready
⚠️ Screens need to be completed (see below)

## Remaining Development Tasks

The following screen files need to be created. I've set up the complete architecture. You can now create these screens:

### Employee Screens (lib/screens/employee/):
1. `mark_attendance_screen.dart` - GPS + Face recognition
2. `attendance_history_screen.dart` - Calendar view
3. `apply_leave_screen.dart` - Leave application form
4. `profile_screen.dart` - User profile

### Admin Screens (lib/screens/admin/):
1. `employees_list_screen.dart` - List all employees
2. `real_time_map_screen.dart` - Google Maps integration
3. `reports_screen.dart` - Generate PDF/Excel reports
4. `manage_leave_screen.dart` - Approve/reject leaves

### Common Screens (lib/screens/common/):
1. `face_capture_screen.dart` - Camera for face capture

Each screen should use the existing services and providers already created in the project.
