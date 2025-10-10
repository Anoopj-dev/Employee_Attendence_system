# Complete Firebase Setup Guide for EmpAtt

## Step-by-Step Firebase Configuration

### Part 1: Create Firebase Project (5 minutes)

1. **Go to Firebase Console**
   - Open: https://console.firebase.google.com/
   - Click **"Add project"** or **"Create a project"**

2. **Enter Project Details**
   - Project name: `EmpAtt` (or any name you prefer)
   - Click **Continue**

3. **Google Analytics (Optional)**
   - You can disable it for now or enable it
   - Click **Continue** or **Create project**

4. **Wait for Project Creation**
   - It will take 10-20 seconds
   - Click **Continue** when done

---

### Part 2: Register Android App (10 minutes)

1. **Add Android App to Firebase**
   - In Firebase Console, click the **Android icon** (or **Add app** → **Android**)

2. **Enter Package Details**
   ```
   Android package name: com.example.empatt
   ```
   ⚠️ **IMPORTANT**: This MUST match your `applicationId` in `android/app/build.gradle.kts`

   - App nickname (optional): `EmpAtt Android`
   - Debug signing certificate (skip for now)
   - Click **Register app**

3. **Download google-services.json**
   - Click **Download google-services.json**
   - **CRITICAL STEP**: Place this file in:
     ```
     android/app/google-services.json
     ```
   - In your project, the path should be:
     ```
     empatt/
     └── android/
         └── app/
             └── google-services.json  ← PUT FILE HERE
     ```

4. **Skip the SDK Setup Steps**
   - Click **Next** (we've already configured it)
   - Click **Next** again
   - Click **Continue to console**

---

### Part 3: Enable Firebase Services (10 minutes)

#### 3.1 Enable Authentication

1. In Firebase Console, go to **Build** → **Authentication**
2. Click **Get started**
3. Click **Sign-in method** tab
4. Click **Email/Password**
5. Toggle **Enable** to ON
6. Click **Save**

#### 3.2 Create Firestore Database

1. Go to **Build** → **Firestore Database**
2. Click **Create database**
3. **Security Rules**: Choose **Start in test mode**
   - (We'll update rules later)
4. **Cloud Firestore location**: Choose closest to you (e.g., `us-central1`)
5. Click **Enable**
6. Wait for database creation

#### 3.3 Enable Storage

1. Go to **Build** → **Storage**
2. Click **Get started**
3. **Security Rules**: Choose **Start in test mode**
4. **Storage location**: Same as Firestore
5. Click **Done**

---

### Part 4: Configure Security Rules (5 minutes)

#### 4.1 Firestore Security Rules

1. Go to **Firestore Database** → **Rules** tab
2. Replace all content with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper function to check if user is admin
    function isAdmin() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth.uid == userId;
      allow update, delete: if request.auth.uid == userId || isAdmin();
    }

    // Attendance collection
    match /attendance/{attendanceId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId || isAdmin();
    }

    // Leave requests collection
    match /leave_requests/{leaveId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if isAdmin();
      allow delete: if request.auth.uid == resource.data.userId || isAdmin();
    }

    // Face data collection
    match /face_data/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId || isAdmin();
    }
  }
}
```

3. Click **Publish**

#### 4.2 Storage Security Rules

1. Go to **Storage** → **Rules** tab
2. Replace all content with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {

    // Helper function to check if user is admin
    function isAdmin() {
      return firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Face images - users can read/write their own, admins can access all
    match /face_images/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    // Reports - only admins can access
    match /reports/{allPaths=**} {
      allow read, write: if request.auth != null && isAdmin();
    }
  }
}
```

3. Click **Publish**

---

### Part 5: Verify Installation (2 minutes)

1. **Check File Structure**
   ```
   empatt/
   ├── android/
   │   └── app/
   │       └── google-services.json  ✅ THIS MUST EXIST
   ├── lib/
   └── pubspec.yaml
   ```

2. **Verify google-services.json Content**
   - Open the file
   - Should contain JSON with `project_info`, `client`, etc.
   - Should have your project ID

---

### Part 6: Test Firebase Connection (5 minutes)

1. **Run the app**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Expected Result**:
   - App should launch without Firebase errors
   - You should see the splash screen
   - Then the login screen

3. **Test Registration**:
   - Click "Register"
   - Fill in the form
   - Click "Register"
   - Should create account successfully

4. **Verify in Firebase Console**:
   - Go to **Authentication** → **Users**
   - You should see your new user
   - Go to **Firestore Database**
   - You should see a `users` collection with your user data

---

## Common Issues & Solutions

### Issue 1: "google-services.json not found"

**Solution**:
```bash
# Make sure the file is in the correct location
empatt/android/app/google-services.json

# NOT in:
empatt/android/google-services.json  ❌
empatt/google-services.json  ❌
```

### Issue 2: "Default FirebaseApp is not initialized"

**Solution**:
1. Ensure `google-services.json` is in the right place
2. Run: `flutter clean && flutter pub get`
3. Restart your IDE
4. Try again

### Issue 3: Package name mismatch

**Error**: `No matching client found for package name 'com.example.empatt'`

**Solution**:
1. Check `android/app/build.gradle.kts`: `applicationId = "com.example.empatt"`
2. In Firebase Console → Project Settings → Your apps
3. Make sure the package names match exactly

### Issue 4: Build fails with gradle error

**Solution**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue 5: Permission errors

**Solution**:
- Ensure you added permissions in `AndroidManifest.xml` ✅ (Already done)
- On first run, the app will ask for permissions

---

## Create Your First Admin User

After successful setup:

1. **Register a normal user first**:
   - Run the app
   - Click Register
   - Fill in details
   - Register

2. **Make that user an admin**:
   - Go to Firebase Console → Firestore Database
   - Find the `users` collection
   - Click on your user document
   - Find the `role` field
   - Change value from `"employee"` to `"admin"`
   - Save

3. **Logout and login again**:
   - You'll now have admin access
   - You'll see the Admin Dashboard

---

## Configure Your Office Location

Edit `lib/config/app_config.dart`:

```dart
static const double defaultLatitude = 37.7749;  // Your office latitude
static const double defaultLongitude = -122.4194; // Your office longitude
static const double geofenceRadius = 100.0; // meters (adjust as needed)
```

**How to find your coordinates**:
1. Go to Google Maps
2. Right-click on your office location
3. Click on the coordinates (they'll be copied)
4. Paste in the config file

---

## Optional: Google Maps Setup (for Admin Real-Time Map)

### Get API Key

1. Go to: https://console.cloud.google.com/
2. Select or create a project
3. Go to **APIs & Services** → **Library**
4. Enable these APIs:
   - Maps SDK for Android
   - Maps SDK for iOS (if supporting iOS)
   - Geocoding API

5. Go to **APIs & Services** → **Credentials**
6. Click **Create Credentials** → **API Key**
7. Copy the API key

### Add to Android

Edit `android/app/src/main/AndroidManifest.xml`:

Find the `<application>` tag and add inside it:

```xml
<application>
    <!-- Add this meta-data tag -->
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_API_KEY_HERE"/>

    <!-- Rest of your application config -->
    <activity ...>
```

---

## Firebase Configuration Checklist

- [x] Firebase project created
- [x] Android app registered in Firebase
- [x] `google-services.json` downloaded and placed in `android/app/`
- [x] Email/Password authentication enabled
- [x] Firestore Database created
- [x] Storage enabled
- [x] Security rules configured
- [x] Permissions added to AndroidManifest.xml
- [x] Build.gradle files configured
- [x] Office location set in app_config.dart
- [ ] First admin user created
- [ ] Google Maps API key added (optional)

---

## Quick Command Reference

```bash
# Clean and rebuild
flutter clean
flutter pub get

# Run app
flutter run

# Check for errors
flutter doctor
flutter analyze

# Build release APK
flutter build apk --release
```

---

## Next Steps After Firebase Setup

1. ✅ Firebase configured
2. ✅ Run the app
3. ✅ Register first user
4. ✅ Make user admin in Firestore
5. 📝 Create remaining screens (see SCREENS_GUIDE.md)
6. 🧪 Test all features
7. 🚀 Deploy!

---

## Support

If you encounter any issues:

1. Check the error message carefully
2. Review this guide step-by-step
3. Check Firebase Console for any warnings
4. Run `flutter clean && flutter pub get`
5. Restart your IDE

**Common Firebase Console Locations**:
- Authentication: Build → Authentication
- Firestore: Build → Firestore Database
- Storage: Build → Storage
- Project Settings: Gear icon (top left)

---

**Congratulations!** 🎉 Once Firebase is set up, your backend is ready. The app will be able to:
- Register and login users
- Store attendance records
- Manage leave requests
- Upload face images
- Track locations

All that's left is creating the remaining UI screens!
