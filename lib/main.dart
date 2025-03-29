import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sdp_app/pages/spalshscreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sdp_app/data.dart';
import 'package:sdp_app/pages/spalshscreen.dart';// Import NavigationItem data

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

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  int _currentIndex = 0;
  late List<NavigationItem> _navigationItems;
  NavigationItem ?  selectedItem;

  @override
  void initState() {
    super.initState();
    _navigationItems = getNavigationItems();
    selectedItem = _navigationItems[_currentIndex]; // Default selection
    requestPermission();
    getFCMToken();
    setupFCMListeners();
    initializeNotifications();
  }

  // Request user permission for notifications
  void requestPermission() async {
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

  // Retrieve and print FCM token (Send this to backend)
  void getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("Firebase Device Token: $token");
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

  // Customizable bottom navbar item
  Widget buildNavigationItem(NavigationItem nav) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedItem = nav;
          _currentIndex = _navigationItems.indexOf(nav);
        });
      },
      child: Container(
        width: 50.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (selectedItem == nav)
              Container(
                height: 50.0,
                width: 50.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF944ef8), // Highlight color
                ),
              ),
            Icon(
              nav.iconData,
              color: Colors.white,
              size: 24.0,
            ),
          ],
        ),
      ),
    );
  }

  // Generate navbar items
  List<Widget> buildNavBar() {
    return _navigationItems.map((nav) => buildNavigationItem(nav)).toList();
  }

  // Custom Bottom Navigation Bar
  Widget _buildBottomNavBar() {

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: 75.0,
        decoration: BoxDecoration(
          color: const Color(0xFFd1b6ed), // Navbar background color
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: buildNavBar(),
        ),
      ),
    );
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
      home: const Spalshscreen(),
    );
  }
}
