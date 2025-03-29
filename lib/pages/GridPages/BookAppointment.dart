import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sdp_app/components/VehicleTypeDropdown.dart';
import 'package:sdp_app/components/CustomerVehicleDropDown.dart';
import 'package:sdp_app/pages/homescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sdp_app/utils/DioInstance.dart';
import 'dart:io';
import 'package:sdp_app/pages/Mainpage.dart';

class Bookappointment extends StatefulWidget {
  const Bookappointment({super.key});

  @override
  State<Bookappointment> createState() => _BookappointmentState();
}

class _BookappointmentState extends State<Bookappointment> {
  bool _isLoading = false;
  String selectedDate = '';
  String selectedTime = '';
  String selectedVehicleNo = '';

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
      initialDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.red,
            colorScheme: ColorScheme.light(primary: Colors.red),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 8, minute: 0),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.red,
            colorScheme: ColorScheme.light(primary: Colors.red),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}:00';
      });
    }
  }

  Future<void> _makeAppointment(BuildContext context) async {
    if (selectedDate.isEmpty || selectedTime.isEmpty || selectedVehicleNo.isEmpty) {
      _showError("Please select Date, Time, and Vehicle.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token'); // Retrieve the token

      if (token == null) {
        _showError("Authentication failed. Please log in again.");
        return;
      }

      Response response = await DioInstance.dio.post(
        "/api/appointments/make-appointment",
        data: {
          "Date": selectedDate,
          "Time": selectedTime,
          "VehicleNo": selectedVehicleNo,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      print("Appointment making response: ${response.data}");

      if (response.statusCode == 201 && response.data['success']) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Mainpage()),
        );
      } else {
        _showError(response.data['message'] ?? "An error occurred. Please try again.");
      }
    } on DioException catch (e) {
      print("Error: ${e.response?.data.toString() ?? e.message}");
      _showError(e.response?.data['message'] ?? "Request failed. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              SizedBox(height: 15.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => Homescreen()));
                    },
                    child: Container(
                      height: 50.0,
                      width: 50.0,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                      child: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.0),
              Text("Book Your Appointment", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 38.0)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Image.asset("images/appointment.png", fit: BoxFit.contain),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Date",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.0),
                          borderSide: BorderSide(color: Colors.red, width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.0),
                          borderSide: BorderSide(color: Colors.redAccent, width: 2.5),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_month, color: Colors.red),
                          onPressed: () {
                            _selectDate(context);
                          },
                        ),
                      ),
                      readOnly: true,
                      onTap: () {
                        _selectDate(context);
                      },
                    ),
                    const SizedBox(height: 17.0),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Time",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.0),
                          borderSide: BorderSide(color: Colors.red, width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.0),
                          borderSide: BorderSide(color: Colors.redAccent, width: 2.5),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.timelapse, color: Colors.red),
                          onPressed: () {
                            _selectTime(context);
                          },
                        ),
                      ),
                      readOnly: true,
                      onTap: () {
                        _selectTime(context);
                      },
                    ),
                    const SizedBox(height: 17.0),
                    CustomerVehicleDropdown(
                      onVehicleSelected: (Vehicle) {
                        setState(() {
                          selectedVehicleNo = Vehicle.vehicleNo;
                        });
                      },
                    ),
                    SizedBox(height: 70.0),
                    ElevatedButton(
                      onPressed: _isLoading ? null : () => _makeAppointment(context),
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : Text(
                        "Book Appointment",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                        minimumSize: const Size(double.infinity, 50),
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
