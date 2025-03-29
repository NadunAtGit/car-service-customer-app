import 'package:flutter/material.dart';
import 'package:sdp_app/data/customer/CustomerVehicle.dart';

class CustomerVehicleDropdown extends StatefulWidget {
  final ValueChanged<Vehicle> onVehicleSelected; // Callback to notify the parent

  const CustomerVehicleDropdown({super.key, required this.onVehicleSelected});

  @override
  State<CustomerVehicleDropdown> createState() => _CustomerVehicleDropdownState();
}

class _CustomerVehicleDropdownState extends State<CustomerVehicleDropdown> {
  List<Vehicle> vehicles = [];
  Vehicle? selectedVehicle; // Holds the selected vehicle

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    List<Vehicle> fetchedVehicles = await getVehicle(); // Fetch vehicles from the data source
    setState(() {
      vehicles = fetchedVehicles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Vehicle>(
      value: selectedVehicle,
      hint: Text("Choose Vehicle"),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: BorderSide(color: Colors.red, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: BorderSide(color: Colors.redAccent, width: 2.5),
        ),
      ),
      icon: Icon(Icons.keyboard_arrow_down, color: Colors.red), // Dropdown icon
      items: vehicles.map((vehicle) {
        return DropdownMenuItem<Vehicle>(
          value: vehicle,
          child: Text(vehicle.vehicleNo), // Display vehicleNo
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
