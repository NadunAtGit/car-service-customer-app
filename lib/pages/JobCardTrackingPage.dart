import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JobCardTrackingPage extends StatefulWidget {
  final Map<String, dynamic>? jobCard;

  const JobCardTrackingPage({super.key, this.jobCard});

  @override
  State<JobCardTrackingPage> createState() => _JobCardTrackingPageState();
}

class _JobCardTrackingPageState extends State<JobCardTrackingPage> {
  @override
  void initState() {
    super.initState();
    // Debug: Print received job card data
    print("JobCardTrackingPage received data: ${widget.jobCard}");

    // Check if Services exists and is a List
    if (widget.jobCard != null) {
      final services = widget.jobCard!['Services'];
      print("Services data type: ${services.runtimeType}");
      print("Services data: $services");

      if (services is List) {
        print("Services count: ${services.length}");
      } else {
        print("Services is not a List");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract job card data
    final jobCard = widget.jobCard;
    if (jobCard == null) {
      print("JobCard is null");
      return Scaffold(
        appBar: AppBar(
          title: Text('Job Card Details'),
        ),
        body: Center(
          child: Text('No job card data available'),
        ),
      );
    }

    // Extract job card details
    final jobCardID = jobCard['JobCardID'] ?? '';
    final type = jobCard['Type'] ?? '';
    final vehicleNo = jobCard['VehicleNo'] ?? '';
    final vehicleModel = jobCard['VehicleModel'] ?? '';
    final serviceDetails = jobCard['ServiceDetails'] ?? '';
    final status = jobCard['Status'] ?? '';

    // Debug: Print all keys in the jobCard
    print("JobCard keys: ${jobCard.keys.toList()}");

    // Safely extract services with proper type checking
    List<dynamic> services = [];
    if (jobCard.containsKey('Services')) {
      final servicesData = jobCard['Services'];
      print("Services data found: $servicesData");

      if (servicesData is List) {
        services = servicesData;
        print("Services list extracted, count: ${services.length}");
      } else {
        print("Services is not a List: ${servicesData.runtimeType}");
      }
    } else {
      print("No 'Services' key found in jobCard");
    }

    // Calculate completed services
    final completedServices = services.where((service) => service['Status'] == 'Finished').length;
    final totalServices = services.length;
    final progressPercentage = totalServices > 0
        ? (completedServices / totalServices) * 100
        : 0.0;

    print("Services count: $totalServices, Completed: $completedServices, Progress: $progressPercentage%");

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: Text(
          'Job Card Status',
          style: GoogleFonts.poppins(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF1E293B),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job Card Summary
                Container(
                  padding: const EdgeInsets.all(20),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C3AED).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.build_rounded,
                              color: Color(0xFF7C3AED),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  jobCardID,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$type Service',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.directions_car_rounded,
                                  size: 16,
                                  color: Color(0xFF3B82F6),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  vehicleNo,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF3B82F6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: getStatusBgColor(status),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Status: $status',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: getStatusColor(status),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Service Details',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        serviceDetails.isNotEmpty ? serviceDetails : 'Service for $vehicleModel',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Progress Section
                Container(
                  padding: const EdgeInsets.all(20),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            '$completedServices of $totalServices completed',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          Container(
                            height: 8,
                            width: MediaQuery.of(context).size.width *
                                (progressPercentage / 100) * 0.8, // Adjust for padding
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${progressPercentage.toStringAsFixed(0)}%',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Service Items Title
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 12),
                  child: Text(
                    'Service Items',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),

                // Service Items
                if (services.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'No service records found',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  )
                else
                  ...services.map<Widget>((service) {
                    print("Rendering service: $service");
                    return ServiceStatusItem(service: service);
                  }).toList(),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'created':
        return Colors.grey.shade700;
      case 'assigned':
        return Colors.blue.shade700;
      case 'ongoing':
        return Colors.orange.shade700;
      case 'finished':
        return Colors.green.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Color getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'created':
        return Colors.grey.shade100;
      case 'assigned':
        return Colors.blue.shade50;
      case 'ongoing':
        return Colors.orange.shade50;
      case 'finished':
        return Colors.green.shade50;
      default:
        return Colors.grey.shade100;
    }
  }
}

class ServiceStatusItem extends StatelessWidget {
  final Map<String, dynamic> service;

  const ServiceStatusItem({
    Key? key,
    required this.service,
  }) : super(key: key);

  Color getStatusColor(String status) {
    switch (status) {
      case 'Not Started':
        return Colors.grey.shade500;
      case 'Started':
      case 'Ongoing':
        return const Color(0xFFF59E0B);
      case 'Finished':
        return const Color(0xFF10B981);
      default:
        return Colors.grey.shade500;
    }
  }

  Color getStatusBgColor(String status) {
    switch (status) {
      case 'Not Started':
        return Colors.grey.shade100;
      case 'Started':
      case 'Ongoing':
        return const Color(0xFFF59E0B).withOpacity(0.1);
      case 'Finished':
        return const Color(0xFF10B981).withOpacity(0.1);
      default:
        return Colors.grey.shade100;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Not Started':
        return Icons.watch_later_outlined;
      case 'Started':
      case 'Ongoing':
        return Icons.engineering_rounded;
      case 'Finished':
        return Icons.check_circle_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug: Print service data
    print("Building ServiceStatusItem with data: $service");

    final serviceDescription = service['Description'] ?? service['ServiceDescription'] ?? 'No description available';
    final serviceType = service['ServiceType'] ?? 'Unknown';
    final status = service['Status'] ?? 'Unknown';
    final serviceId = service['ServiceRecord_ID'] ?? '';

    print("Service details - Description: $serviceDescription, Type: $serviceType, Status: $status, ID: $serviceId");

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    serviceType == 'Repair'
                        ? Icons.handyman_rounded
                        : Icons.search_rounded,
                    color: const Color(0xFF7C3AED),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    serviceDescription,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  serviceType,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: getStatusBgColor(status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        getStatusIcon(status),
                        size: 14,
                        color: getStatusColor(status),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        status,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: getStatusColor(status),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'ID: $serviceId',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
