import 'package:flutter/material.dart';
import 'package:sdp_app/pages/AddVehicle.dart';// Import your AddVehicle screen

class Vehiclesnav extends StatefulWidget {
  const Vehiclesnav({super.key});

  @override
  State<Vehiclesnav> createState() => _VehiclesnavState();
}

class _VehiclesnavState extends State<Vehiclesnav> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAEAEA),
      body: const SafeArea(
        child: Column(
          children: [
            Row(), // Add your UI components here
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Addvehicle()),
          );
        },
        backgroundColor: Colors.purple, // Customize color
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
