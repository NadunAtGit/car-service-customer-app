import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sdp_app/utils/DioInstance.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String time;
  final String type;
  final IconData icon;
  final Color color;
  final String NavigateID;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
    required this.type,
    required this.NavigateID,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    String notificationId = json['notification_id'] ?? ''; // Changed from 'id' to 'notification_id'
    print('Notification ID: $notificationId'); // Debugging print statement

    return AppNotification(
      id: notificationId,
      title: json['title'] ?? 'Notification',
      message: json['message'] ?? '',
      time: _formatTime(json['created_at'] ?? DateTime.now().toIso8601String()),
      icon: _getIcon(json['icon_type'] ?? json['notification_type'] ?? ''),
      color: _hexToColor(json['color_code'] ?? '#6C4DF6'),
      type: json['notification_type'] ?? 'default',
      NavigateID: json['navigate_id'] ?? '',
    );
  }


  // Override the toString method to return a readable format
  @override
  String toString() {
    return 'AppNotification(id: $id, title: $title, message: $message, time: $time, type: $type)';
  }

  static String _formatTime(String isoString) {
    final dt = DateTime.parse(isoString).toLocal();
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hour(s) ago';
    return '${difference.inDays} day(s) ago';
  }

  static IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'calendar_today':
      case 'reschedule appointment':
      case 'appointment':
        return Icons.calendar_today;
      case 'build':
      case 'job card':
      case 'service':
        return Icons.build;
      case 'check_circle':
      case 'complete':
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.notifications;
    }
  }

  static Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
}

Future<List<AppNotification>> fetchCustomerNotifications() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print("Token is missing.");
      return []; // Return empty list if token is missing
    }

    Response response = await DioInstance.dio.get(
      "/api/customers/notifications",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    if (response.statusCode == 200 && response.data["success"] == true) {
      print("Fetched notifications successfully");
      List notificationList = response.data["notifications"];
      return notificationList.map((item) => AppNotification.fromJson(item)).toList();
    } else {
      print("Failed to fetch notifications: ${response.data}");
      return [];
    }
  } catch (e) {
    print("Error fetching notifications: $e");
    return [];
  }
}

Future<List<AppNotification>> getNotifications() async {
  return await fetchCustomerNotifications();
}