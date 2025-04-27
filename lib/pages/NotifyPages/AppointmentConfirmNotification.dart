import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sdp_app/utils/DioInstance.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Appointmentconfirmnotification extends StatefulWidget {
  final String? appointmentId;

  const Appointmentconfirmnotification({super.key, this.appointmentId});

  @override
  State<Appointmentconfirmnotification> createState() => _AppointmentconfirmnotificationState();
}

class _AppointmentconfirmnotificationState extends State<Appointmentconfirmnotification> {
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _appointmentData;

  @override
  void initState() {
    super.initState();
    _fetchAppointmentDetails();
  }

  Future<void> _fetchAppointmentDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Get the appointment ID from widget or from notification data
      final appointmentId = widget.appointmentId ?? '';

      if (appointmentId.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Appointment ID is missing';
        });
        return;
      }

      // Get token for authentication
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Authentication token not found';
        });
        return;
      }

      // Fetch appointment details from API
      final response = await DioInstance.getRequest(
        '/api/appointments/appointment/$appointmentId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response != null &&
          response.statusCode == 200 &&
          response.data['success'] == true) {
        setState(() {
          _appointmentData = response.data['appointment'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = response?.data['error'] ?? 'Failed to load appointment details';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';

    try {
      final date = DateTime.parse(dateString);
      return DateFormat('EEEE, MMMM d, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatTime(String? timeString) {
    if (timeString == null) return 'N/A';

    try {
      // Handle different time formats
      if (timeString.contains('T')) {
        final dateTime = DateTime.parse(timeString);
        return DateFormat('h:mm a').format(dateTime);
      } else {
        // Parse time string like "08:00:00"
        final timeParts = timeString.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final dateTime = DateTime(2025, 4, 20, hour, minute); // Using current date from search results
        return DateFormat('h:mm a').format(dateTime);
      }
    } catch (e) {
      return timeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Appointment Confirmation',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Error Loading Appointment',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchAppointmentDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Try Again',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Success Icon and Message
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green[600],
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Appointment Confirmed!',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your appointment has been confirmed successfully.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Appointment Details Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appointment Details',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Appointment ID
                      _buildDetailRow(
                        Icons.confirmation_number_outlined,
                        'Appointment ID',
                        _appointmentData?['AppointmentID'] ?? 'N/A',
                      ),
                      const SizedBox(height: 16),

                      // Date
                      _buildDetailRow(
                        Icons.calendar_today,
                        'Date',
                        _formatDate(_appointmentData?['Date']),
                      ),
                      const SizedBox(height: 16),

                      // Time
                      _buildDetailRow(
                        Icons.access_time,
                        'Time',
                        _formatTime(_appointmentData?['Time']),
                      ),
                      const SizedBox(height: 16),

                      // Vehicle
                      _buildDetailRow(
                        Icons.directions_car_outlined,
                        'Vehicle',
                        _appointmentData?['VehicleID'] ?? 'N/A',
                      ),
                      const SizedBox(height: 16),

                      // Status
                      _buildDetailRow(
                        Icons.check_circle_outline,
                        'Status',
                        _appointmentData?['Status'] ?? 'N/A',
                        valueColor: Colors.green,
                      ),

                      if (_appointmentData?['Notes'] != null && _appointmentData!['Notes'].toString().isNotEmpty) ...[
                        const SizedBox(height: 16),
                        // Notes
                        _buildDetailRow(
                          Icons.note_outlined,
                          'Notes',
                          _appointmentData?['Notes'],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // What's Next Section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "What's Next?",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "• Please arrive 10 minutes before your scheduled time",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "• Bring your vehicle registration documents",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "• If you need to reschedule, please do so at least 24 hours in advance",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: Text(
                        'Back to Notifications',
                        style: GoogleFonts.poppins(),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
