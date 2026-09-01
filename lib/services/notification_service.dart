import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notification_demo/main.dart';
import 'package:push_notification_demo/screens/notification_screen.dart';

class FireBasePushNotification {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void permissionRequest() async {
    NotificationSettings settings = await messaging.requestPermission(
      sound: true,
      provisional: true,
      criticalAlert: true,
      carPlay: true,
      announcement: true,
      badge: true,
      alert: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Permission Granted');
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('Permission Denied');
    } else {
      debugPrint('User Denied');
    }
  }

  Future<void> initialize() async {
    if (Platform.isIOS) {
      try {
        messaging.requestPermission(sound: true);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    enableIOSNotifications();
    messaging.setAutoInitEnabled(true);
    debugPrint('Initializing Firebase Push Notification');

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      "message",
      "High Importance Notification",
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      playSound: true,
    );

    messaging.setForegroundNotificationPresentationOptions(
      sound: true,
      badge: true,
      alert: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (payload) async {
        dynamic body = jsonDecode(payload.payload!);
        log("Payload body: $body");
        navigateToOtherScreen();
      },
    );
    FirebaseMessaging.onBackgroundMessage(
          (event) async {
        log('$event', error: "Terminate");
        navigateToOtherScreen();
      },
    );

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('Received a message while in foreground');
      debugPrint('Message data: ${message.data}');
      showNotification(message.notification!, message.data, channel);
      if (message.notification != null) {
        debugPrint('Message also contains notification: ${message.notification}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('onMessageOpenedApp: ${message.data}');
      navigateToOtherScreen();
    });

    FirebaseMessaging.instance.getInitialMessage().then((event) async {
      log('getInitialMessage: $event');
      if (event != null) {
        navigateToOtherScreen();
      }
    });

    await getToken();
  }
  /// Required to display a heads up notification
  Future<void> enableIOSNotifications() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  Future<String?> getToken() async {
    if (Platform.isIOS) {
      messaging.requestPermission();
    }
    try {
      var token = await messaging.getToken();
      log('FCM Token $token');
      return token;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  void showNotification(RemoteNotification message, Map data, AndroidNotificationChannel channel) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      playSound: true,
      importance: Importance.max,
      priority: Priority.high,
      channelShowBadge: true,
      enableLights: true,
      category: AndroidNotificationCategory.social,
    );

    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    try {
      await flutterLocalNotificationsPlugin.show(
        id: 0,
        title: message.title,
        body: message.body,
        notificationDetails: platformChannelSpecifics,
        payload: json.encode(data),
      );
      debugPrint('Notification shown with title: ${message.title}, body: ${message.body}');
    } on Exception catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  void navigateToOtherScreen() {
    debugPrint('Navigating to other screen');
    navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (context) => const NotificationScreen(),
    ));
  }
}