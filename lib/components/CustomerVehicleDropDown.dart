// File: lib/components/CustomerVehicleDropDown.dart
import 'package:flutter/material.dart';
import 'package:sdp_app/data/customer/CustomerVehicle.dart';

class CustomerVehicleDropdown extends StatefulWidget {
  final Function(Vehicle) onVehicleSelected; // Callback to notify the parent

  const CustomerVehicleDropdown({Key? key, required this.onVehicleSelected}) : super(key: key);

  @override
  State<CustomerVehicleDropdown> createState() => _CustomerVehicleDropdownState();
}

class _CustomerVehicleDropdownState extends State<CustomerVehicleDropdown> {
  List<Vehicle> vehicles = [];
  Vehicle? selectedVehicle; // Holds the selected vehicle
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      List<Vehicle> fetchedVehicles = await getVehicle(); // Fetch vehicles from the data source

      setState(() {
        vehicles = fetchedVehicles;
        isLoading = false;

        // If no vehicles are found, set an error message
        if (vehicles.isEmpty) {
          errorMessage = "No vehicles found. Please add a vehicle first.";
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Failed to load vehicles: $e";
      });
      print("Error loading vehicles: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (vehicles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          "No vehicles available. Please add a vehicle first.",
          style: TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    return DropdownButtonFormField<Vehicle>(
      value: selectedVehicle,
      hint: const Text("Choose Vehicle"),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(color: Color(0xFF944EF8), width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(color: Color(0xFF944EF8), width: 2.5),
        ),
      ),
      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF944EF8)), // Dropdown icon
      items: vehicles.map((vehicle) {
        return DropdownMenuItem<Vehicle>(
          value: vehicle,
          child: Text("${vehicle.vehicleNo} - ${vehicle.model}"), // Display vehicleNo and model
        );
      }).toList(),
      onChanged: (Vehicle? newValue) {
        setState(() {
          selectedVehicle = newValue;
        });
        if (newValue != null) {
          widget.onVehicleSelected(newValue); // Notify parent widget about the selected vehicle
        }
      },
    );
  }
}