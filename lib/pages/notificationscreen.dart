import 'package:flutter/material.dart';
import 'package:sdp_app/data/Notifications/NotificationData.dart';
import 'NotifyPages/RescheduleAppointments.dart';
import 'package:sdp_app/pages/NotifyPages/AppointmentConfirmNotification.dart';
import 'package:sdp_app/pages/NotifyPages/JobCardCreated.dart';
import 'package:sdp_app/pages/NotifyPages/AssignedWorkersNotification.dart';
import 'package:sdp_app/pages/NotifyPages/RatingPage.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  Future<List<AppNotification>> _notificationFuture = getNotifications();
  String _selectedFilter = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Notifications",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Divider(
                thickness: 1.5,
                color: Colors.grey[300],
                indent: 8.0,
                endIndent: 8.0,
              ),
              const SizedBox(height: 16.0),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: "All",
                      selected: _selectedFilter == "All",
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedFilter = "All";
                            _refreshNotifications();
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: "Job Cards",
                      selected: _selectedFilter == "Job Cards",
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedFilter = "Job Cards";
                            _refreshNotifications();
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: "Appointments",
                      selected: _selectedFilter == "Appointments",
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedFilter = "Appointments";
                            _refreshNotifications();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),

              // Notifications List
              Expanded(
                child: FutureBuilder<List<AppNotification>>(
                  future: _notificationFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          "No notifications yet",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    } else {
                      final notifications = snapshot.data!;

                      // Filter notifications based on the selected filter
                      List<AppNotification> filteredNotifications = notifications;
                      if (_selectedFilter == "Job Cards") {
                        filteredNotifications = notifications
                            .where((n) => n.type.toLowerCase().contains('job') ||
                            n.type.toLowerCase().contains('service'))
                            .toList();
                      } else if (_selectedFilter == "Appointments") {
                        filteredNotifications = notifications
                            .where((n) => n.type.toLowerCase().contains('appointment'))
                            .toList();
                      }

                      return RefreshIndicator(
                        onRefresh: _refreshNotifications,
                        child: ListView.builder(
                          itemCount: filteredNotifications.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: NotificationCard(notification: filteredNotifications[index]),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      _notificationFuture = getNotifications();
    });
  }
}

class FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(bool) onSelected;

  const FilterChip({
    Key? key,
    required this.label,
    required this.selected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(true),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: selected ? Colors.blue : Colors.grey[200],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final AppNotification notification;

  const NotificationCard({
    super.key,
    required this.notification,
  });

  void _handleTap(BuildContext context) {
    // Use NavigateID if it's not empty, otherwise fall back to notification.id
    String appointmentId = notification.NavigateID.isNotEmpty ? notification.NavigateID : notification.id;

    // Debugging: Check what's being assigned to appointmentId
    print("Notification ID: $appointmentId");

    if (notification.type.toLowerCase() == 'reschedule appointment' && appointmentId.isNotEmpty) {
      // Extract appointment details from the notification message
      print("Notification ID: $appointmentId");

      // Parse date and time from the message
      RegExp dateRegex = RegExp(r'(\d{4}-\d{2}-\d{2})');
      RegExp timeRegex = RegExp(r'(\d{2}:\d{2}):\d{2}');

      String? date;
      String? time;

      final dateMatch = dateRegex.firstMatch(notification.message);
      if (dateMatch != null) {
        date = dateMatch.group(1);
      }

      final timeMatch = timeRegex.firstMatch(notification.message);
      if (timeMatch != null) {
        time = timeMatch.group(1);
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RescheduleAppointments(
            appointmentId: appointmentId,
            title: notification.title,
            message: notification.message,
            timeAgo: notification.time,
            initialDate: date,
            initialTime: time,
          ),
        ),
      );
    } else if(notification.type.toLowerCase() == 'appointment confirmed' && appointmentId.isNotEmpty){
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Appointmentconfirmnotification(appointmentId: appointmentId)
        ),
      );
    }else if(notification.type.toLowerCase() == 'job card' && appointmentId.isNotEmpty){
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Jobcardcreated(jobCardId: appointmentId)
        ),
      );
    }else if(notification.type.toLowerCase() == 'mechanic assignment' && appointmentId.isNotEmpty){
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Assignedworkersnotification(jobCardId: appointmentId)
        ),
      );
    }else if(notification.type.toLowerCase() == 'job card completed' && appointmentId.isNotEmpty){
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Ratingpage(jobCardId: appointmentId)
        ),
      );
    }
    else {
      // Handle other notification types here
      print("Tapped notification of type: ${notification.type}");

      // Print the appointmentId safely, since it's now always initialized
      print("Appointment ID: $appointmentId");

      print(notification);
    }
  }




  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _handleTap(context),
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: notification.color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: notification.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(notification.icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notification.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          notification.time,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 14,
                      ),
                    ),
                    if (notification.type.toLowerCase() == 'reschedule appointment')
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.touch_app, size: 14, color: Colors.blue[700]),
                            const SizedBox(width: 4),
                            Text(
                              "Tap to reschedule",
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}