// File: lib/pages/Bookappointment.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sdp_app/components/CustomerVehicleDropDown.dart';
import 'package:sdp_app/pages/Mainpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sdp_app/utils/DioInstance.dart';
import 'package:intl/intl.dart';

import '../../data/customer/CustomerVehicle.dart';

class Bookappointment extends StatefulWidget {
  const Bookappointment({super.key});

  @override
  State<Bookappointment> createState() => _BookappointmentState();
}

class _BookappointmentState extends State<Bookappointment> {
  final List<String> timeSlots = ["08:00", "09:30", "11:00", "12:30", "14:00", "15:30"];
  bool _isLoading = false;
  String selectedDate = '';
  String selectedTime = '';
  String selectedVehicleNo = '';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      // initialDate: DateTime.now().add(const Duration(days: 1)),
      initialDate: DateTime.now(),
      // firstDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C4DF6),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
      print("Selected date: $selectedDate");
    }
  }

  Future<void> _makeAppointment() async {
    if (selectedDate.isEmpty || selectedTime.isEmpty || selectedVehicleNo.isEmpty) {
      _showError("Please select all required fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _showError("Authentication failed. Please log in again.");
        return;
      }

      // Format time to match backend's expected format
      final formattedTime = "$selectedTime:00";

      // Debug: Print request details
      print("Making appointment with the following details:");
      print("Date: $selectedDate");
      print("Time: $formattedTime");
      print("VehicleNo: $selectedVehicleNo");
      print("API URL: ${DioInstance.dio.options.baseUrl}/api/appointments/make-appointment");
      print("Token: ${token.substring(0, 10)}..."); // Only print part of the token for security

      // Prepare the request body
      final requestBody = {
        "Date": selectedDate,
        "Time": formattedTime,
        "VehicleNo": selectedVehicleNo,
      };

      print("Request Body: $requestBody");

      final response = await DioInstance.dio.post(
        "/api/appointments/make-appointment",
        data: requestBody,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      // Debug: Print response details
      print("API Response Status: ${response.statusCode}");
      print("API Response Data: ${response.data}");

      if (response.statusCode == 201) {
        _showSuccess("Appointment booked successfully!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Mainpage()),
        );
      } else {
        _showError(response.data['message'] ?? response.data['error'] ?? "Failed to book appointment");
      }
    } on DioException catch (e) {
      // Extensive error logging
      print("=== API ERROR DETAILS ===");
      print("DioException: ${e.toString()}");
      print("Error Type: ${e.type}");
      print("Error Message: ${e.message}");

      if (e.response != null) {
        print("Response Status Code: ${e.response?.statusCode}");
        print("Response Headers: ${e.response?.headers.map}");
        print("Response Data: ${e.response?.data}");
      }

      print("Request Path: ${e.requestOptions.path}");
      print("Request Method: ${e.requestOptions.method}");
      print("Request Headers: ${e.requestOptions.headers}");
      print("Request Data: ${e.requestOptions.data}");
      print("Request URI: ${e.requestOptions.uri}");
      print("=== END ERROR DETAILS ===");

      // Extract error message from various possible sources
      String errorMessage;
      if (e.response != null) {
        if (e.response?.data is Map) {
          errorMessage = e.response?.data['message'] ??
              e.response?.data['error'] ??
              "Server error (${e.response?.statusCode})";
        } else {
          errorMessage = "Server error (${e.response?.statusCode})";
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = "Connection timeout. Please check your network.";
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = "Server is taking too long to respond. Please try again.";
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = "Could not connect to the server. Please check your network connection.";
      } else {
        errorMessage = "Network error. Please check your connection. (${e.type})";
      }

      _showError(errorMessage);
    } catch (e) {
      print("General error: ${e.toString()}");
      _showError("An unexpected error occurred: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    print("ERROR: $message"); // Also log to console
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 5), // Show longer to read error
      ),
    );
  }

  void _showSuccess(String message) {
    print("SUCCESS: $message"); // Also log to console
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            // Back button
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF6C4DF6)),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),

            // Header
            Text(
              'Book Service Appointment',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select your preferred date, time and vehicle',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),

            // Date Selection Card
            GlassCard(
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Color(0xFF6C4DF6)),
                title: Text(
                  selectedDate.isEmpty ? 'Select Date' : selectedDate,
                  style: TextStyle(
                    color: selectedDate.isEmpty ? Colors.grey : Colors.black87,
                  ),
                ),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () => _selectDate(context),
              ),
            ),
            const SizedBox(height: 20),

            // Time Slots Grid
            Text(
              'Available Time Slots',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.8,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: timeSlots.map((slot) {
                final isSelected = selectedTime == slot;
                return GestureDetector(
                  onTap: () => setState(() => selectedTime = slot),
                  child: GlassCard(
                    color: isSelected ? const Color(0xFF6C4DF6).withOpacity(0.1) : null,
                    borderColor: isSelected ? const Color(0xFF6C4DF6) : Colors.grey[300],
                    child: Center(
                      child: Text(
                        slot,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? const Color(0xFF6C4DF6) : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Vehicle Selection
            Text(
              'Select Vehicle',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 10),
            GlassCard(
              child: CustomerVehicleDropdown(
                onVehicleSelected: (vehicle) {
                  setState(() {
                    selectedVehicleNo = vehicle.vehicleNo;
                  });
                  print("Selected vehicle: ${vehicle.vehicleNo}");
                },
              ),
            ),
            const SizedBox(height: 30),

            // Book Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (selectedDate.isNotEmpty &&
                    selectedTime.isNotEmpty &&
                    selectedVehicleNo.isNotEmpty &&
                    !_isLoading)
                    ? _makeAppointment
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C4DF6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'BOOK APPOINTMENT',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color ?? Colors.white.withOpacity(0.9),
        border: Border.all(
          color: borderColor ?? Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}