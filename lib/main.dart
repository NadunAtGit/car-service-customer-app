import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sdp_app/pages/NotifyPages/RescheduleAppointments.dart';
import 'package:sdp_app/pages/spalshscreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sdp_app/data.dart';
import 'package:sdp_app/utils/DioInstance.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Set the status bar to transparent
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // Add this static method to make it accessible from anywhere
  static Future<void> updateFCMTokenAfterLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? customerId = prefs.getString('customerId');
      String? token = prefs.getString('fcm_token');

      print("DEBUGGING FCM: Updating token after login. Customer ID exists? ${customerId != null}");
      print("DEBUGGING FCM: Updating token after login. Token exists? ${token != null}");

      if (customerId != null && token != null) {
        // Changed parameter names to match API expectations
        final requestData = {
          'customerId': customerId,    // Changed from 'customer_id'
          'firebaseToken': token,      // Changed from 'firebase_token'
        };

        print("DEBUGGING FCM: Sending login update request: $requestData");

        final response = await DioInstance.postRequest(
          '/api/customers/update-fcm-token',
          requestData,
        );

        print("DEBUGGING FCM: Server response after login: ${response?.statusCode} - ${response?.data}");

        if (response == null) {
          print("DEBUGGING FCM: No response received from server during login update!");
        }
      } else {
        print("DEBUGGING FCM: Cannot update token - missing customerId or token");
      }
    } catch (e) {
      print('DEBUGGING FCM: Error updating FCM token after login: $e');
      if (e is DioException) {
        print('DEBUGGING FCM: DioError type: ${e.type}');
        print('DEBUGGING FCM: DioError message: ${e.message}');
        print('DEBUGGING FCM: DioError response: ${e.response?.data}');
      }
    }
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  int _currentIndex = 0;
  late List<NavigationItem> _navigationItems;
  NavigationItem? selectedItem;

  @override
  void initState() {
    super.initState();
    _navigationItems = getNavigationItems();
    selectedItem = _navigationItems[_currentIndex];
    initializeFirebaseMessaging();
    initializeNotifications();
  }

  // Initialize all FCM-related functionality
  void initializeFirebaseMessaging() async {
    await requestPermission();

    // Instead of sending token immediately, just store it locally
    await getAndStoreLocalFCMToken();

    // Check if user is already logged in, then try to update token
    updateFCMTokenIfLoggedIn();

    setupFCMListeners();

    // Listen for token refreshes
    messaging.onTokenRefresh.listen((token) {
      // Store the new token locally
      storeTokenLocally(token);
      // Try to send it if logged in
      updateFCMTokenIfLoggedIn();
    });
  }

  // Request user permission for notifications
  Future<void> requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted permission");
    } else {
      print("User declined permission");
    }
  }

  // Retrieve FCM token and store locally (don't send yet)
  Future<void> getAndStoreLocalFCMToken() async {
    try {
      String? token = await messaging.getToken();
      print("Token retrieval completed. Token exists? ${token != null}");
      if (token != null) {
        print("Firebase Device Token: $token");
        await storeTokenLocally(token);
      }
    } catch (e) {
      print("Error getting FCM token: $e");
    }
  }

  // Store FCM token locally
  Future<void> storeTokenLocally(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      print("DEBUGGING FCM: FCM token stored locally for later use");
    } catch (e) {
      print("DEBUGGING FCM: Error storing FCM token locally: $e");
    }
  }

  // Check if user is logged in and update FCM token if they are
  Future<void> updateFCMTokenIfLoggedIn() async {
    try {
      String? customerId = await getCustomerId();

      if (customerId == null) {
        print("DEBUGGING FCM: User not logged in yet, token update skipped");
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('fcm_token');

      if (token != null) {
        await sendTokenToServer(token, customerId);
      } else {
        print("DEBUGGING FCM: No stored FCM token found");
      }
    } catch (e) {
      print("DEBUGGING FCM: Error in updateFCMTokenIfLoggedIn: $e");
    }
  }

  // Get customer ID from shared preferences
  Future<String?> getCustomerId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('customerId');
    } catch (e) {
      print("DEBUGGING FCM: Error getting customer ID: $e");
      return null;
    }
  }

  // Send token to your backend server using Dio
  Future<void> sendTokenToServer(String token, String customerId) async {
    try {
      // Changed parameter names to match API expectations
      final requestData = {
        'customerId': customerId,  // Changed from 'customer_id'
        'firebaseToken': token,    // Changed from 'firebase_token'
      };
      print("DEBUGGING FCM: Sending to server: $requestData");

      final response = await DioInstance.postRequest(
        '/api/customers/update-fcm-token',
        requestData,
      );

      print("DEBUGGING FCM: Server response: ${response?.statusCode} - ${response?.data}");

      if (response == null) {
        print("DEBUGGING FCM: No response received from server!");
      } else if (response.statusCode == 200) {
        print("DEBUGGING FCM: Token successfully updated on server");
      } else {
        print("DEBUGGING FCM: Server returned non-200 status: ${response.statusCode}");
      }
    } catch (e) {
      print('DEBUGGING FCM: Error sending token to server: $e');
      // Print more detailed error information if available
      if (e is DioException) {
        print('DEBUGGING FCM: DioError type: ${e.type}');
        print('DEBUGGING FCM: DioError message: ${e.message}');
        print('DEBUGGING FCM: DioError response: ${e.response?.data}');
      }
    }
  }

  // Setup listeners for notifications
  void setupFCMListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground notification received: ${message.notification?.title}");
      showNotification(
        message.notification?.title ?? "Notification",
        message.notification?.body ?? "You have a new update!",
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("User clicked on notification: ${message.notification?.title}");
    });
  }

  // Initialize local notifications
  void initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Show local notification when app is in foreground
  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        'high_importance_channel', 'High Importance Notifications',
        importance: Importance.max, priority: Priority.high);

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Service Center Management System',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.mulishTextTheme(),
      ),
      debugShowCheckedModeBanner: false,
      home: Spalshscreen(),
    );
  }
}