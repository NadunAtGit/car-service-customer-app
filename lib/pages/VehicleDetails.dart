import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sdp_app/utils/DioInstance.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ServiceRecordsPage.dart';

class JobCard {
  final String jobCardId;
  final String serviceDetails;
  final String type;
  final String? invoiceId;
  final String appointmentId;
  final String status;

  JobCard({
    required this.jobCardId,
    required this.serviceDetails,
    required this.type,
    required this.invoiceId,
    required this.appointmentId,
    required this.status,
  });

  factory JobCard.fromJson(Map<String, dynamic> json) {
    return JobCard(
      jobCardId: json['JobCardID'],
      serviceDetails: json['ServiceDetails'],
      type: json['Type'],
      invoiceId: json['InvoiceID'],
      appointmentId: json['AppointmentID'],
      status: json['Status'],
    );
  }
}

class AppointmentWithJobCards {
  final String vehicleId;
  final String appointmentId;
  final List<JobCard> jobCards;

  AppointmentWithJobCards({
    required this.vehicleId,
    required this.appointmentId,
    required this.jobCards,
  });

  factory AppointmentWithJobCards.fromJson(Map<String, dynamic> json) {
    return AppointmentWithJobCards(
      vehicleId: json['VehicleID'],
      appointmentId: json['AppointmentID'],
      jobCards: (json['JobCards'] as List)
          .map((jc) => JobCard.fromJson(jc))
          .toList(),
    );
  }
}

Future<List<AppointmentWithJobCards>> fetchJobCards(String vehicleNo) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print("Token is missing.");
      return [];
    }

    final response = await DioInstance.getRequest(
      '/api/customers/getjobcards/$vehicleNo',
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    if (response != null &&
        response.statusCode == 200 &&
        response.data["message"] == "Job cards fetched successfully") {
      print("Fetched job cards successfully");
      return (response.data["data"] as List)
          .map((item) => AppointmentWithJobCards.fromJson(item))
          .toList();
    } else {
      print("Failed to fetch job cards: ${response?.data}");
      return [];
    }
  } catch (e) {
    print("Error fetching job cards: $e");
    return [];
  }
}

class VehicleDetailsPage extends StatefulWidget {
  final String vehicleNo;

  const VehicleDetailsPage({super.key, required this.vehicleNo});

  @override
  State<VehicleDetailsPage> createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage> {
  List<AppointmentWithJobCards> appointments = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadJobCards();
  }

  Future<void> _loadJobCards() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final jobCards = await fetchJobCards(widget.vehicleNo);
      setState(() {
        appointments = jobCards;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load job cards: ${e.toString()}';
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green.shade600;
      case 'in progress':
        return Colors.amber.shade700;
      case 'created':
        return Colors.blue.shade600;
      case 'pending':
        return Colors.orange.shade600;
      case 'cancelled':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return '✓';
      case 'in progress':
        return '⚙️';
      case 'created':
        return '📝';
      case 'pending':
        return '⏳';
      case 'cancelled':
        return '✗';
      default:
        return '•';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.primaryColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              widget.vehicleNo,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadJobCards,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadJobCards,
        child: CustomScrollView(
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.directions_car_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Maintenance History',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'All job cards for your vehicle',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Content
            isLoading
                ? SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: theme.primaryColor,
                ),
              ),
            )
                : errorMessage.isNotEmpty
                ? SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48,
                        color: Colors.red.shade400
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load job cards',
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadJobCards,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            )
                : appointments.isEmpty
                ? SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No job cards found',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your vehicle has no service history yet',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final appointment = appointments[index];
                  return AppointmentCard(
                    appointment: appointment,
                    getStatusColor: _getStatusColor,
                    getStatusIcon: _getStatusIcon,
                  );
                },
                childCount: appointments.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final AppointmentWithJobCards appointment;
  final Color Function(String) getStatusColor;
  final String Function(String) getStatusIcon;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    required this.getStatusColor,
    required this.getStatusIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Appointment',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#${appointment.appointmentId}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${appointment.jobCards.length} job card${appointment.jobCards.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ...appointment.jobCards.map((jobCard) => JobCardItem(
            jobCard: jobCard,
            getStatusColor: getStatusColor,
            getStatusIcon: getStatusIcon,
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class JobCardItem extends StatelessWidget {
  final JobCard jobCard;
  final Color Function(String) getStatusColor;
  final String Function(String) getStatusIcon;

  const JobCardItem({
    Key? key,
    required this.jobCard,
    required this.getStatusColor,
    required this.getStatusIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorForStatus = getStatusColor(jobCard.status);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceRecordsPage(jobCardId: jobCard.jobCardId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            color: theme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            jobCard.jobCardId,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorForStatus.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorForStatus.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  getStatusIcon(jobCard.status),
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  jobCard.status,
                                  style: TextStyle(
                                    color: colorForStatus,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service Details',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          jobCard.serviceDetails,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.category_outlined,
                        'Type',
                        jobCard.type,
                        Colors.blue.shade100,
                        Colors.blue.shade900,
                      ),
                      const SizedBox(width: 12),
                      if (jobCard.invoiceId != null)
                        _buildInfoChip(
                          Icons.receipt_outlined,
                          'Invoice',
                          jobCard.invoiceId!,
                          Colors.green.shade100,
                          Colors.green.shade900,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ServiceRecordsPage(jobCardId: jobCard.jobCardId),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View Service Records',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: theme.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
      IconData icon,
      String label,
      String value,
      Color bgColor,
      Color textColor,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: textColor.withOpacity(0.8),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}