# Troubleshooting Guide

## Current Errors and How to Fix Them

### Error 1: RegisterScreen is not a class

**Error Message**: `The name 'RegisterScreen' isn't a class`

**Location**: `lib/screens/auth/login_screen.dart:231`

**Cause**: The `register_screen.dart` file exists but is empty or incomplete.

**Solution**:
Create the file with this complete code:

**File**: `lib/screens/auth/register_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _departmentController = TextEditingController();
  final _designationController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        role: UserRole.employee,
        department: _departmentController.text.trim(),
        designation: _designationController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please login.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Registration failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Fill in your details to register',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _departmentController,
                  decoration: const InputDecoration(
                    labelText: 'Department (Optional)',
                    hintText: 'e.g., Engineering',
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _designationController,
                  decoration: const InputDecoration(
                    labelText: 'Designation (Optional)',
                    hintText: 'e.g., Software Engineer',
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Register',
                              style: TextStyle(fontSize: 16),
                            ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

After creating this file, the error will be resolved.

---

### Error 2: Missing Screen Files

**Errors**:
- `Target of URI doesn't exist: 'mark_attendance_screen.dart'`
- `Target of URI doesn't exist: 'attendance_history_screen.dart'`
- etc.

**Cause**: Screen files haven't been created yet.

**Solution**: Create the missing screen files. See **SCREENS_GUIDE.md** for templates.

**Quick fix** - Create empty placeholder files:

```bash
cd lib/screens/employee
touch mark_attendance_screen.dart attendance_history_screen.dart apply_leave_screen.dart profile_screen.dart

cd ../admin
touch employees_list_screen.dart real_time_map_screen.dart reports_screen.dart manage_leave_screen.dart

cd ../common
touch face_capture_screen.dart
```

Then add basic placeholder code to each:

```dart
import 'package:flutter/material.dart';

class MarkAttendanceScreen extends StatelessWidget {
  const MarkAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
      ),
      body: const Center(
        child: Text('Coming Soon'),
      ),
    );
  }
}
```

---

## Common Runtime Errors

### Error: Default FirebaseApp is not initialized

**Solution**:
1. Make sure `google-services.json` is in `android/app/`
2. Run: `flutter clean && flutter pub get`
3. Restart your IDE
4. Follow **FIREBASE_SETUP_GUIDE.md** completely

---

### Error: Location permission denied

**Solution**:
- The app will request permissions on first use
- If denied, user must enable in phone settings
- Go to: Settings → Apps → EmpAtt → Permissions

---

### Error: Camera permission denied

**Solution**:
Same as location - enable in phone settings

---

### Error: Face detection failed

**Possible causes**:
1. Poor lighting
2. Face not centered
3. Face too small/far
4. Multiple faces in frame

**Solution**:
- Ensure good lighting
- Center face in camera
- Move closer to camera
- Only one face in frame

---

### Error: Not within geofence

**Solution**:
1. Check office coordinates in `lib/config/app_config.dart`
2. Increase geofence radius if needed:
   ```dart
   static const double geofenceRadius = 200.0; // Increased from 100
   ```
3. For testing, you can temporarily use your current location as office location

---

## Build Errors

### Gradle build failed

**Solution**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Multidex error

**Solution**: Already fixed - `multiDexEnabled = true` is in build.gradle.kts

### Firebase plugin version mismatch

**Solution**:
```bash
flutter pub upgrade
flutter clean
flutter pub get
```

---

## Quick Fixes Checklist

Before asking for help, try these:

- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Restart your IDE
- [ ] Check `google-services.json` is in correct location
- [ ] Verify Firebase is enabled (Authentication, Firestore, Storage)
- [ ] Check internet connection
- [ ] Update Flutter: `flutter upgrade`
- [ ] Check Flutter doctor: `flutter doctor`

---

## File Location Reference

```
empatt/
├── android/
│   ├── app/
│   │   ├── google-services.json  ← FIREBASE CONFIG FILE
│   │   ├── build.gradle.kts       ← GRADLE CONFIG
│   │   └── src/main/AndroidManifest.xml  ← PERMISSIONS
│   └── build.gradle.kts
├── lib/
│   ├── config/
│   │   └── app_config.dart        ← OFFICE LOCATION HERE
│   ├── screens/
│   │   ├── auth/
│   │   │   └── register_screen.dart  ← CREATE THIS
│   │   ├── employee/              ← CREATE SCREENS HERE
│   │   ├── admin/                 ← CREATE SCREENS HERE
│   │   └── common/                ← CREATE SCREENS HERE
│   └── main.dart
└── pubspec.yaml
```

---

## Getting Help

1. **Check error message** - Read it carefully
2. **Search this file** - Ctrl+F for keywords from error
3. **Check Firebase Console** - Look for warnings/errors
4. **Review setup guides**:
   - FIREBASE_SETUP_GUIDE.md
   - README.md
   - PROJECT_SUMMARY.md

---

## Success Indicators

✅ App launches without errors
✅ Can register new user
✅ Can see user in Firebase Console → Authentication
✅ Can see user data in Firestore → users collection
✅ Can login with registered user
✅ Redirected to appropriate dashboard (Employee/Admin)

If all above work, your setup is correct!
