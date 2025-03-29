import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:sdp_app/pages/GridPages/BookAppointment.dart';
import 'package:sdp_app/pages/GridPages/BreakdownService.dart';
import 'package:sdp_app/pages/GridPages/EvCharging.dart';
import 'package:sdp_app/pages/GridPages/AssistantScreen.dart';
import 'package:sdp_app/pages/NavPages/AppointmentsNav.dart';
import 'package:sdp_app/pages/NavPages/VehiclesNav.dart';
import 'package:sdp_app/pages/NavPages/PaymentsNav.dart';
import 'package:sdp_app/pages/homescreen.dart';




import 'package:flutter/material.dart';

class GridItem {
  final IconData icon;
  final String text;
  final Widget destination; // Destination widget

  // Constructor
  GridItem({
    required this.icon,
    required this.text,
    required this.destination,
  });
}

// Function to return a list of grid items
List<GridItem> getGridItems(BuildContext context) {
  return <GridItem>[
    GridItem(
      icon: Icons.calendar_today,
      text: "Schedule",
      destination: Bookappointment(),
    ),
    GridItem(
      icon: Icons.car_crash,
      text: "Career",
      destination: Breakdownservice(),
    ),
    GridItem(
      icon: Icons.ev_station,
      text: "Charging",
      destination: Evcharging(),
    ),
    GridItem(
      icon: Icons.support_agent,
      text: "Assistant",
      destination: Assistantscreen(),
    ),
  ];
}


class NavigationItem {
  final IconData iconData;
  final String label;
  final Widget page;

  NavigationItem(this.iconData, this.label, this.page);
}

List<NavigationItem> getNavigationItems() {
  return <NavigationItem>[
              // Payments
    NavigationItem(Icons.home, "Home", const Homescreen()),
    NavigationItem(Icons.calendar_today, "Appointments", Appointmentsnav()),
    NavigationItem(Icons.directions_car, "Services", Vehiclesnav()),
    NavigationItem(Icons.payment, "Payments", Paymentsnav()),
    // Job Cards
    // Profile
  ];
}




