import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sdp_app/data/Appointments/AppointmentData.dart';

class Appointmentsnav extends StatefulWidget {
  const Appointmentsnav({super.key});

  @override
  State<Appointmentsnav> createState() => _AppointmentsnavState();
}

class _AppointmentsnavState extends State<Appointmentsnav> {
  // Lists to store appointments
  List<Appointment> _confirmedAppointments = [];
  List<Appointment> _unconfirmedAppointments = [];
  Appointment? _closestAppointment;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    print("Loading appointments in AppointmentsNav...");
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch confirmed appointments from the API
      final confirmedAppointments = await getConfirmedAppointments();
      // Fetch not confirmed appointments
      final notConfirmedAppointments = await getNotConfirmedAppointments();
      // Get the closest confirmed appointment
      final closestAppointment = await getClosestConfirmedAppointment();

      if (mounted) {
        setState(() {
          _confirmedAppointments = confirmedAppointments;
          _unconfirmedAppointments = notConfirmedAppointments;
          _closestAppointment = closestAppointment;
          _isLoading = false;
        });
      }

      print("Loaded ${confirmedAppointments.length} confirmed appointments");
      print("Loaded ${notConfirmedAppointments.length} unconfirmed appointments");
      print("Closest appointment: ${closestAppointment?.id ?? 'None'}");
    } catch (e) {
      print("Error loading appointments: $e");
      if (mounted) {
        setState(() {
          _error = "Failed to load appointments: $e";
          _isLoading = false;
        });
      }
    }
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    return DateFormat('EEE, MMM d, yyyy').format(date);
  }

  // Helper method to format time
  String _formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  // Get confirmed appointments (excluding the closest appointment)
  List<Appointment> get _otherConfirmedAppointments {
    if (_closestAppointment == null) return _confirmedAppointments;

    return _confirmedAppointments
        .where((apt) => apt.id != _closestAppointment!.id)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAEAEA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAppointments,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadAppointments,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Your Appointments",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),

                // Current date display
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Today is Saturday, April 19, 2025",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Next Confirmed Appointment Section - Below today's date
                if (_closestAppointment != null) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Next Appointment",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  NextAppointmentCard(appointment: _closestAppointment!),
                  const SizedBox(height: 20),
                ],

                // Unconfirmed Appointments Section (Pending Confirmation)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Pending Confirmation",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),

                _unconfirmedAppointments.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      "No pending appointments",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _unconfirmedAppointments.length,
                  itemBuilder: (context, index) {
                    return AppointmentListItem(
                      appointment: _unconfirmedAppointments[index],
                      formatDate: _formatDate,
                      formatTime: _formatTime,
                      isPending: true,
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Confirmed Appointments Section (moved after Pending Confirmation)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Confirmed Appointments",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),

                _otherConfirmedAppointments.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      "No other confirmed appointments",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _otherConfirmedAppointments.length,
                  itemBuilder: (context, index) {
                    return AppointmentListItem(
                      appointment: _otherConfirmedAppointments[index],
                      formatDate: _formatDate,
                      formatTime: _formatTime,
                    );
                  },
                ),

                // Space at the bottom for FAB
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create new appointment page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Book a new appointment')),
          );
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class NextAppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const NextAppointmentCard({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF944EF8), Color(0xFF7A3CD3)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Appointment header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF944EF8),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(appointment.dateTime),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('h:mm a').format(appointment.dateTime),
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: appointment.isConfirmed ? Colors.green[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment.isConfirmed ? 'Confirmed' : 'Pending',
                    style: TextStyle(
                      color: appointment.isConfirmed ? Colors.green[800] : Colors.orange[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Appointment details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Vehicle
                Row(
                  children: [
                    const Icon(Icons.directions_car_outlined, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Vehicle',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${appointment.vehicleModel} (${appointment.vehicleNumber})',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Notes if available
                if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.notes_outlined, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Notes',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              appointment.notes!,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Implement reschedule functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reschedule appointment')),
                          );
                        },
                        icon: const Icon(Icons.edit_calendar_outlined),
                        label: const Text('Reschedule'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF944EF8),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Implement cancel functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cancel appointment')),
                          );
                        },
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Cancel'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[50],
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppointmentListItem extends StatelessWidget {
  final Appointment appointment;
  final Function(DateTime) formatDate;
  final Function(DateTime) formatTime;
  final bool isPending;

  const AppointmentListItem({
    super.key,
    required this.appointment,
    required this.formatDate,
    required this.formatTime,
    this.isPending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isPending
            ? const BorderSide(color: Colors.orange, width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          // View appointment details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('View appointment ${appointment.id} details')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appointment header with date and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatDate(appointment.dateTime),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPending ? Colors.orange[100] : Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isPending ? 'Pending' : 'Confirmed',
                      style: TextStyle(
                        color: isPending ? Colors.orange[800] : Colors.green[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Service details
              Row(
                children: [
                  const Icon(Icons.schedule, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    formatTime(appointment.dateTime),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Vehicle details
              Row(
                children: [
                  const Icon(Icons.directions_car, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${appointment.vehicleModel} (${appointment.vehicleNumber})',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Notes if available
              if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.notes, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appointment.notes!,
                        style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Actions for pending appointments
              if (isPending) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Confirm appointment
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Confirm appointment')),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                      child: const Text('Confirm'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        // Cancel appointment
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cancel appointment')),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
