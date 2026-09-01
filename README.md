# Firebase Push Notification in Flutter

A comprehensive guide and sample Flutter application demonstrating how to integrate **Firebase Cloud Messaging (FCM)** and **Flutter Local Notifications** to handle push notifications across Foreground, Background, and Terminated app states, including payload-based navigation.

---

## 🚀 Features

- **Multi-State Notification Handling**:
  - **Foreground**: Notifications displayed heads-up using `flutter_local_notifications`.
  - **Background**: Received via system tray; clicking opens the app and navigates to the target screen.
  - **Terminated**: Wakes the app and retrieves initial message on launch.
- **Deep Linking / Screen Navigation**: Automatically navigates to a specific screen when a notification is tapped.
- **Cross-Platform Support**: Configured for both **Android** and **iOS**.
- **Permission Management**: Runtime notification permission requests for Android 13+ and iOS.
- **FCM Token Retrieval**: Easy access to device FCM token for targeted messaging.

---

## 📋 Prerequisites

- Flutter SDK (`>=3.3.4 <4.0.0`)
- Firebase Account & Project in [Firebase Console](https://console.firebase.google.com/)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli) installed and configured

---

## 🛠️ Step-by-Step Setup Guide

### 1. Configure Firebase in your Flutter Project

Follow the official FlutterFire setup guide or use the CLI:
```bash
# Install FlutterFire CLI if not already installed
dart pub global activate flutterfire_cli

# Configure your project
flutterfire configure
```
This generates `lib/firebase_options.dart` with platform-specific Firebase configuration.

---

### 2. Add Dependencies

Add the following dependencies in your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^4.14.0
  firebase_messaging: ^16.6.0
  flutter_local_notifications: ^22.3.0
```

Run `flutter pub get` to install the packages.

---

### 3. Platform Configurations

#### 🤖 Android Setup

1. **Add Permissions in `android/app/src/main/AndroidManifest.xml`**:
   Place inside the `<manifest>` tag:
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
   ```

2. **Add Metadata and Intent Filters**:
   Place inside the `<activity>` tag in `AndroidManifest.xml`:
   ```xml
   <!-- Default Notification Channel -->
   <meta-data
       android:name="com.google.firebase.messaging.default_notification_channel_id"
       android:value="message" />

   <!-- Default Notification Icon -->
   <meta-data
       android:name="com.google.firebase.messaging.default_notification_icon"
       android:resource="@drawable/ic_launcher" />

   <!-- Flutter Notification Click Intent Filter -->
   <intent-filter>
       <action android:name="FLUTTER_NOTIFICATION_CLICK" />
       <category android:name="android.intent.category.DEFAULT" />
   </intent-filter>
   ```

#### 🍏 iOS Setup

1. **Enable Background Modes in `ios/Runner/Info.plist`**:
   Add the following inside `<dict>`:
   ```xml
   <key>UIBackgroundModes</key>
   <array>
       <string>fetch</string>
       <string>remote-notification</string>
   </array>
   ```

2. **Apple Developer Account**:
   - Enable **Push Notifications** and **Background Modes (Remote notifications)** in Xcode under *Signing & Capabilities*.
   - Upload your APNs Auth Key (`.p8`) to Firebase Console under Project Settings > Cloud Messaging > Apple app configuration.

---

### 4. Code Implementation

#### A. Initialize in `lib/main.dart`

Define the top-level background handler and initialize Firebase before `runApp()`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:push_notification_demo/firebase_options.dart';
import 'package:push_notification_demo/screens/home_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Get and print FCM token
  final fcmToken = await FirebaseMessaging.instance.getToken();
  debugPrint('FCM Token: $fcmToken');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: const HomeScreen(),
    );
  }
}
```

#### B. Setup Notification Service (`lib/services/notification_service.dart`)

The notification service encapsulates:
- Requesting user permissions.
- Setting up the notification channel and local notification plugin.
- Handling foreground messages (`FirebaseMessaging.onMessage`).
- Handling background clicks (`FirebaseMessaging.onMessageOpenedApp`).
- Handling terminated state clicks (`FirebaseMessaging.instance.getInitialMessage()`).
- Navigating to target screens (`navigateToOtherScreen()`).

Refer to the full implementation: [notification_service.dart](file:///Users/dreamworld/Documents/prodev-mob/firebase_push_notification/lib/services/notification_service.dart)

---

## 🧪 Testing Push Notifications via Firebase Console

1. Open your project in the [Firebase Console](https://console.firebase.google.com/).
2. Navigate to **Engage** > **Messaging** (or **Cloud Messaging**) and click **Create your first campaign** (or **New campaign**).

   ![Create Campaign](https://github.com/ProdevSoftware/firebase_push_notification/assets/97152083/44c563cc-e96b-4b32-9c9e-17c6bcb0eba7)

3. Select **Firebase Notification messages**.

   ![Select Notification Messages](https://github.com/ProdevSoftware/firebase_push_notification/assets/97152083/be0ca6af-4467-42d6-ad8b-94fe78d08e06)

4. Enter the **Notification title** and **Notification text**, then click **Send test message**.

   ![Add Title & Body](https://github.com/ProdevSoftware/firebase_push_notification/assets/97152083/7475fee8-fa34-4358-a7ee-ae681b6c6467)

5. Paste the **FCM registration token** copied from your app logs and click **Test**.

---

## 🎥 Demo Video

Watch the sample demonstration:

https://github.com/ProdevSoftware/firebase_push_notification/assets/97152083/7309f10d-08db-42ed-a6a0-8a3dd89463e1
