import 'package:flutter/material.dart';

class VehicleTypeDropdown extends StatefulWidget {
  final Function(String?) onChanged;

  const VehicleTypeDropdown({Key? key, required this.onChanged}) : super(key: key);

  @override
  _VehicleTypeDropdownState createState() => _VehicleTypeDropdownState();
}

class _VehicleTypeDropdownState extends State<VehicleTypeDropdown> {
  String? _selectedVehicleType;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: DropdownButton<String>(
          hint: Text(
            _selectedVehicleType ?? "Vehicle Type",
            style: TextStyle(color: Colors.black),
          ),
          isExpanded: true,
          items: [
            DropdownMenuItem<String>(value: "SUV", child: Text("SUV")),
            DropdownMenuItem<String>(value: "EV", child: Text("EV")),
            DropdownMenuItem<String>(value: "Hybrid", child: Text("Hybrid")),
            DropdownMenuItem<String>(value: "PickUp", child: Text("PickUp")),
          ],
          onChanged: (String? newValue) {
            setState(() {
              _selectedVehicleType = newValue;
            });
            widget.onChanged(_selectedVehicleType); // Notify parent widget
          },
          underline: SizedBox(),
        ),
      ),
    );
  }
}

