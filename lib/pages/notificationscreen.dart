import 'package:flutter/material.dart';

class Notificationscreen extends StatefulWidget {
  const Notificationscreen({super.key});

  @override
  State<Notificationscreen> createState() => _NotificationscreenState();
}

class _NotificationscreenState extends State<Notificationscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0), // Added padding for better layout
          child: Column(

            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 10), // Space between profile pic and text
                  const Text(
                    "Notifications",
                    style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
                  ),
                  Divider(
                    thickness: 1.5,  // Adjust thickness for better visibility
                    color: Colors.grey[300],  // Light grey color
                    indent: 8.0,  // Left margin
                    endIndent: 100.0,  // Right margin
                  ),

                  SizedBox(height: 20.0,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 120.0,
                        width: double.infinity,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.red,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Column(
                            
                          )],
                        ),

                      )
                    ],
                  )
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
