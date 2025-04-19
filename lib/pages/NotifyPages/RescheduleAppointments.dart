import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sdp_app/utils/DioInstance.dart';
import 'package:intl/intl.dart';

import '../../components/CustomerVehicleDropDown.dart';
import '../Mainpage.dart';

class RescheduleAppointments extends StatefulWidget {
  final String appointmentId;
  final String title;
  final String message;
  final String timeAgo;
  final String? initialDate;
  final String? initialTime;

  const RescheduleAppointments({
    super.key,
    required this.appointmentId,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.initialDate,
    this.initialTime,
  });

  @override
  State<RescheduleAppointments> createState() => _RescheduleAppointmentsState();
}

class _RescheduleAppointmentsState extends State<RescheduleAppointments> {
  final List<String> timeSlots = ["08:00", "09:30", "11:00", "12:30", "14:00", "15:30"];
  bool _isLoading = false;
  String selectedDate = '';
  String selectedTime = '';

  bool _initialLoadCompleted = false;

  @override
  void initState() {
    super.initState();
    // Delay to allow for widget to be fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getAppointmentDetails();
    });
  }

  Future<void> _getAppointmentDetails() async {
    setState(() => _isLoading = true);

    // Set initial values if available from notification
    if (widget.initialDate != null && widget.initialDate!.isNotEmpty) {
      selectedDate = widget.initialDate!;
    }

    if (widget.initialTime != null && widget.initialTime!.isNotEmpty) {
      selectedTime = widget.initialTime!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print("Appointment ID being sent: ${widget.appointmentId}");

      if (token == null) {
        _showError("Authentication failed. Please log in again.");
        return;
      }

      // Fetch appointment details using the appointmentId
      final response = await DioInstance.dio.get(
        "/api/appointments/appointment/${widget.appointmentId}",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        final appointmentData = response.data['data'];

        setState(() {
          // Autofill vehicle information if available


          // If date and time weren't set from notification, use from appointment data
          if (selectedDate.isEmpty && appointmentData['date'] != null) {
            selectedDate = appointmentData['date'];
          }

          if (selectedTime.isEmpty && appointmentData['time'] != null) {
            // Convert time format if needed (e.g., "14:00:00" to "14:00")
            String timeStr = appointmentData['time'];
            if (timeStr.contains(':')) {
              selectedTime = timeStr.substring(0, 5);
            }
          }
        });
      }
    } catch (e) {
      print("Error fetching appointment details: $e");

      _showError("Could not fetch appointment details. Please try again.");
    } finally {
      setState(() {
        _isLoading = false;
        _initialLoadCompleted = true;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate.isNotEmpty
          ? DateTime.parse(selectedDate)
          : DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
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
    }
  }

  Future<void> _makeAppointment() async {
    if (selectedDate.isEmpty || selectedTime.isEmpty) {
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

      final formattedTime = "$selectedTime:00";
      final requestBody = {
        "Date": selectedDate,  // Only send Date and Time
        "Time": formattedTime,
      };

      final response = await DioInstance.dio.put(
        "/api/appointments/reschedule-appointment-customer/${widget.appointmentId}",
        data: requestBody,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        _showSuccess("Appointment rescheduled successfully!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Mainpage()),
        );
      } else {
        _showError(response.data['message'] ?? response.data['error'] ?? "Failed to reschedule appointment");
      }
    } on DioException catch (e) {
      _showError("Error: ${e.response?.data['error'] ?? e.message}");
    } catch (e) {
      _showError("An unexpected error occurred: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccess(String message) {
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
      body: _isLoading && !_initialLoadCompleted
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C4DF6)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF6C4DF6)),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
            Text(
              'Reschedule Appointment',
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


            const SizedBox(height: 20),

            // Date Picker
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              childAspectRatio: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: timeSlots.map((slot) {
                final isSelected = selectedTime == slot;
                return GestureDetector(
                  onTap: () => setState(() => selectedTime = slot),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: isSelected ? const Color(0xFF6C4DF6).withOpacity(0.1) : Colors.white,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF6C4DF6) : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        slot,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? const Color(0xFF6C4DF6) : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (selectedDate.isNotEmpty &&
                    selectedTime.isNotEmpty &&

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
                  'Confirm Reschedule',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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