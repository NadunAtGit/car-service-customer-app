import 'package:flutter/material.dart';
import 'package:sdp_app/utils/DioInstance.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ServiceRecord {
  final String recordId;
  final String description;
  final String jobCardId;
  final String vehicleId;
  final String serviceType;
  final String status;

  ServiceRecord({
    required this.recordId,
    required this.description,
    required this.jobCardId,
    required this.vehicleId,
    required this.serviceType,
    required this.status,
  });

  factory ServiceRecord.fromJson(Map<String, dynamic> json) {
    return ServiceRecord(
      recordId: json['ServiceRecord_ID'],
      description: json['Description'],
      jobCardId: json['JobCardID'],
      vehicleId: json['VehicleID'],
      serviceType: json['ServiceType'],
      status: json['Status'],
    );
  }
}

class Mechanic {
  final String employeeId;
  final String name;
  final String role;
  final double rating;
  final String? profilePicUrl;

  Mechanic({
    required this.employeeId,
    required this.name,
    required this.role,
    required this.rating,
    this.profilePicUrl,
  });

  factory Mechanic.fromJson(Map<String, dynamic> json) {
    return Mechanic(
      employeeId: json['employeeId'],
      name: json['name'],
      role: json['role'],
      rating: json['rating'] is int
          ? (json['rating'] as int).toDouble()
          : json['rating'] is String
          ? double.tryParse(json['rating']) ?? 0.0
          : json['rating'] ?? 0.0,
      profilePicUrl: json['profilePicUrl'],
    );
  }
}

class ServiceRecordsPage extends StatefulWidget {
  final String jobCardId;

  const ServiceRecordsPage({super.key, required this.jobCardId});

  @override
  State<ServiceRecordsPage> createState() => _ServiceRecordsPageState();
}

class _ServiceRecordsPageState extends State<ServiceRecordsPage> {
  List<ServiceRecord> records = [];
  List<ServiceRecord> filteredRecords = [];
  List<Mechanic> mechanics = [];
  bool isLoading = true;
  bool isLoadingMechanics = true;
  String errorMessage = '';
  String mechanicsErrorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  int _currentMechanicIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadServiceRecords();
    _loadAssignedMechanics();
    _searchController.addListener(_filterRecords);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadServiceRecords() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await DioInstance.getRequest(
        '/api/customers/servicerecords/${widget.jobCardId}',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response != null &&
          response.statusCode == 200 &&
          response.data["success"] == true) {
        setState(() {
          records = (response.data["serviceRecords"] as List)
              .map((item) => ServiceRecord.fromJson(item))
              .toList();
          filteredRecords = List.from(records);
          isLoading = false;
        });
      } else {
        throw Exception(response?.data["message"] ?? 'Failed to load records');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadAssignedMechanics() async {
    setState(() {
      isLoadingMechanics = true;
      mechanicsErrorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await DioInstance.getRequest(
        '/api/customers/get-assigned-workers/${widget.jobCardId}',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response != null &&
          response.statusCode == 200 &&
          response.data["success"] == true) {
        setState(() {
          mechanics = (response.data["assignedMechanics"] as List)
              .map((item) => Mechanic.fromJson(item))
              .toList();
          isLoadingMechanics = false;
        });
      } else {
        throw Exception(response?.data["message"] ?? 'Failed to load mechanics');
      }
    } catch (e) {
      setState(() {
        isLoadingMechanics = false;
        mechanicsErrorMessage = e.toString();
      });
    }
  }

  void _filterRecords() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredRecords = records.where((record) {
        return record.description.toLowerCase().contains(query) ||
            record.serviceType.toLowerCase().contains(query) ||
            record.status.toLowerCase().contains(query);
      }).toList();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'finished':
        return Colors.green.shade600;
      case 'in progress':
      case 'ongoing':
      case 'started':
        return Colors.amber.shade700;
      case 'not started':
        return Colors.grey.shade600;
      default:
        return Colors.blue.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xffac75ff),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Records',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              'Job Card: ${widget.jobCardId}',
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
            onPressed: () {
              _loadServiceRecords();
              _loadAssignedMechanics();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadServiceRecords();
          await _loadAssignedMechanics();
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search service records',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: Icon(Icons.search, color: theme.primaryColor),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey.shade600),
                      onPressed: () {
                        _searchController.clear();
                        _filterRecords();
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: theme.primaryColor),
                    ),
                  ),
                ),
              ),
            ),

            // Mechanics section
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.engineering,
                              size: 20,
                              color: theme.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Assigned Mechanics',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (mechanics.length > 1)
                          Row(
                            children: List.generate(mechanics.length, (index) {
                              return Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentMechanicIndex == index
                                      ? theme.primaryColor
                                      : Colors.grey.shade300,
                                ),
                              );
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    isLoadingMechanics
                        ? Center(
                      child: SizedBox(
                        height: 150,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    )
                        : mechanicsErrorMessage.isNotEmpty
                        ? Center(
                      child: Column(
                        children: [
                          Icon(Icons.error_outline,
                              size: 40,
                              color: Colors.red.shade400
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load mechanics',
                            style: TextStyle(color: Colors.red.shade400),
                          ),
                          TextButton(
                            onPressed: _loadAssignedMechanics,
                            child: const Text('Try Again'),
                          )
                        ],
                      ),
                    )
                        : mechanics.isEmpty
                        ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.engineering_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No mechanics assigned yet',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        : SizedBox(
                      height: 180,
                      child: mechanics.length <= 2
                      // Use Row for small number of mechanics
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: mechanics
                            .map(
                              (mechanic) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: MechanicCard(mechanic: mechanic),
                          ),
                        )
                            .toList(),
                      )
                      // Use CarouselSlider for more mechanics
                          : CarouselSlider.builder(
                        itemCount: mechanics.length,
                        options: CarouselOptions(
                          height: 180,
                          enlargeCenterPage: true,
                          viewportFraction: 0.4,
                          enableInfiniteScroll: mechanics.length > 3,
                          autoPlay: mechanics.length > 3,
                          autoPlayInterval: const Duration(seconds: 5),
                          autoPlayAnimationDuration: const Duration(milliseconds: 800),
                          pauseAutoPlayOnTouch: true,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentMechanicIndex = index;
                            });
                          },
                        ),
                        itemBuilder: (context, index, realIndex) {
                          return MechanicCard(mechanic: mechanics[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Service Records Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.assignment,
                      size: 20,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Service Tasks',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!isLoading && filteredRecords.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${filteredRecords.length}',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Service records list
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
                      'Failed to load service records',
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadServiceRecords,
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
                : filteredRecords.isEmpty
                ? SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchController.text.isEmpty
                          ? 'No service records found'
                          : 'No matching records found',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          _filterRecords();
                        },
                        child: const Text('Clear Search'),
                      ),
                  ],
                ),
              ),
            )
                : SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final record = filteredRecords[index];
                  return ServiceRecordCard(
                    record: record,
                    getStatusColor: _getStatusColor,
                  );
                },
                childCount: filteredRecords.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceRecordCard extends StatelessWidget {
  final ServiceRecord record;
  final Color Function(String) getStatusColor;

  const ServiceRecordCard({
    Key? key,
    required this.record,
    required this.getStatusColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Implement detailed view if needed
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      record.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: getStatusColor(record.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: getStatusColor(record.status).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      record.status,
                      style: TextStyle(
                        color: getStatusColor(record.status),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoItem(
                    Icons.build_outlined,
                    'Type',
                    record.serviceType,
                  ),
                  const SizedBox(width: 24),
                  _buildInfoItem(
                    Icons.tag_outlined,
                    'ID',
                    record.recordId,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MechanicCard extends StatelessWidget {
  final Mechanic mechanic;

  const MechanicCard({Key? key, required this.mechanic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: mechanic.profilePicUrl != null
                      ? NetworkImage(mechanic.profilePicUrl!)
                      : null,
                  child: mechanic.profilePicUrl == null
                      ? Text(
                    mechanic.name.isNotEmpty
                        ? mechanic.name.substring(0, 1).toUpperCase()
                        : "M",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  )
                      : null,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 14,
                      color: Colors.amber.shade300,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      mechanic.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              mechanic.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              mechanic.role,
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}