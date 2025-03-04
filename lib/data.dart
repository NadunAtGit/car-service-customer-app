import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';





class GridItem {
  final IconData icon;
  final String text;

  // Constructor
  GridItem({
    required this.icon,
    required this.text,
  });
}

// Function to return a list of grid items
List<GridItem> getGridItems() {
  return <GridItem>[
    GridItem(icon: Icons.calendar_today, text: "Book Appointments"),
    GridItem(icon: Icons.car_crash, text: "Breakdown Service"),
    GridItem(icon: Icons.ev_station, text: "EV Charging"),
    GridItem(icon: Icons.support_agent, text: "Assistant"),
  ];
}

class NavigationItem {

  IconData iconData;

  NavigationItem(this.iconData);

}

List<NavigationItem> getNavigationItems() {
  return <NavigationItem>[
    NavigationItem(Icons.home),             // Home
    NavigationItem(Icons.calendar_today),   // Appointments
    NavigationItem(Icons.payment),          // Payments
    NavigationItem(Icons.work),             // Job Cards
               // Profile
  ];
}




