# Quick Start Guide - EmpAtt

## 🚀 Getting Started in 3 Steps

### Step 1: Firebase Setup (30 minutes) ⚠️ CRITICAL

**Follow this guide**: [`FIREBASE_SETUP_GUIDE.md`](FIREBASE_SETUP_GUIDE.md)

**Quick checklist**:
1. Create Firebase project
2. Add Android app
3. Download `google-services.json` → place in `android/app/`
4. Enable Authentication (Email/Password)
5. Create Firestore Database
6. Enable Storage

**Verification**: File `android/app/google-services.json` should exist

---

### Step 2: Run the App (5 minutes)

```bash
# Clean and get dependencies
flutter clean
flutter pub get

# Run on device/emulator
flutter run
```

**Expected result**: App launches → Splash screen → Login screen

---

### Step 3: Test Registration & Login (5 minutes)

1. Click **"Register"** on login screen
2. Fill in the form:
   - Name: Test User
   - Email: test@example.com
   - Phone: 1234567890
   - Password: test123
3. Click **"Register"**
4. Should show success message
5. Go back and **Login** with same credentials

**Verify in Firebase**:
- Firebase Console → Authentication → Users (should see your user)
- Firestore Database → users collection (should have user data)

---

## 📂 What's Already Done

✅ **Complete architecture** - All services, models, providers
✅ **Firebase integration** - Auth, Firestore, Storage configured
✅ **Core screens** - Login, Register, Dashboards
✅ **Location service** - GPS & geofencing ready
✅ **Face recognition** - ML Kit integrated
✅ **State management** - Provider pattern implemented

---

## ⚠️ What's Missing

You need to create **8 more screen files**:

### Employee Screens
1. `lib/screens/employee/mark_attendance_screen.dart`
2. `lib/screens/employee/attendance_history_screen.dart`
3. `lib/screens/employee/apply_leave_screen.dart`
4. `lib/screens/employee/profile_screen.dart`

### Admin Screens
5. `lib/screens/admin/employees_list_screen.dart`
6. `lib/screens/admin/real_time_map_screen.dart`
7. `lib/screens/admin/reports_screen.dart`
8. `lib/screens/admin/manage_leave_screen.dart`

**Code templates available in**: [`SCREENS_GUIDE.md`](SCREENS_GUIDE.md)

---

## 🏢 Configure Office Location

Edit [`lib/config/app_config.dart`](lib/config/app_config.dart):

```dart
static const double defaultLatitude = 37.7749;  // ← Change this
static const double defaultLongitude = -122.4194; // ← Change this
static const double geofenceRadius = 100.0; // meters
```

**To get your coordinates**:
1. Open Google Maps
2. Right-click on your location
3. Click the coordinates (copies them)
4. Paste in config file

---

## 👤 Create Admin User

After first registration:

1. Login to Firebase Console
2. Go to **Firestore Database**
3. Find `users` collection
4. Click on your user document
5. Edit `role` field: change `"employee"` → `"admin"`
6. Save
7. Logout and login again in app
8. You'll now see Admin Dashboard

---

## 🛠️ Troubleshooting

### App won't build?
```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter run
```

### Firebase errors?
- Check [`FIREBASE_SETUP_GUIDE.md`](FIREBASE_SETUP_GUIDE.md)
- Verify `google-services.json` is in `android/app/`
- Ensure Firebase services are enabled

### Other errors?
- See [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md)

---

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| [`README.md`](README.md) | Project overview & features |
| [`FIREBASE_SETUP_GUIDE.md`](FIREBASE_SETUP_GUIDE.md) | **Complete Firebase setup (START HERE)** |
| [`PROJECT_SUMMARY.md`](PROJECT_SUMMARY.md) | Architecture & what's completed |
| [`SCREENS_GUIDE.md`](SCREENS_GUIDE.md) | Code templates for screens |
| [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) | Common errors & fixes |
| [`QUICK_START.md`](QUICK_START.md) | This file |

---

## 🎯 Project Status

| Component | Status |
|-----------|--------|
| Dependencies | ✅ Complete |
| Firebase Config Files | ✅ Complete |
| Models | ✅ Complete |
| Services | ✅ Complete |
| Providers | ✅ Complete |
| Core Screens | ✅ Complete |
| Auth Screens | ✅ Complete |
| Employee Screens | ⚠️ 8 screens to create |
| Admin Screens | ⚠️ Included in above |
| Documentation | ✅ Complete |

---

## ⏱️ Time Estimates

- Firebase setup: 30 min
- Create missing screens: 4-6 hours
- Testing & fixes: 2 hours
- **Total: ~1 working day**

---

## ✅ Success Checklist

- [ ] Firebase project created
- [ ] `google-services.json` in correct location
- [ ] App runs without errors
- [ ] Can register new user
- [ ] User appears in Firebase Console
- [ ] Can login successfully
- [ ] Admin user created
- [ ] Office location configured
- [ ] All screens created
- [ ] Tested mark attendance flow
- [ ] Tested leave application flow
- [ ] Admin can view employees
- [ ] Reports generation works

---

## 🚀 Next Steps

1. **FIRST**: Complete Firebase setup ([`FIREBASE_SETUP_GUIDE.md`](FIREBASE_SETUP_GUIDE.md))
2. Run the app and test login/register
3. Create missing screens using templates
4. Set your office location
5. Create admin user
6. Test all features
7. Deploy!

---

## 💡 Pro Tips

- Start with Firebase setup - nothing works without it
- Test each screen as you create it
- Use existing services - don't create new ones
- Check Firebase Console regularly to verify data
- Keep geofence radius large during development (200m)
- Use emulator location spoofing to test geofencing

---

## 📞 Need Help?

1. Check error message in console
2. Search [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md)
3. Review [`FIREBASE_SETUP_GUIDE.md`](FIREBASE_SETUP_GUIDE.md)
4. Check Firebase Console for errors
5. Run `flutter clean && flutter pub get`

---

**You're ready to go! Start with Firebase setup, then the rest is straightforward.** 🎉
