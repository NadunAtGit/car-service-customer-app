import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sdp_app/utils/DioInstance.dart';

class Assignedworkersnotification extends StatefulWidget {
  final String jobCardId;
  const Assignedworkersnotification({super.key, required this.jobCardId});

  @override
  State<Assignedworkersnotification> createState() => _AssignedworkersnotificationState();
}

class _AssignedworkersnotificationState extends State<Assignedworkersnotification> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<dynamic> _workers = [];

  // Color theme based on #d9baf4
  final Color primaryColor = const Color(0xFFd9baf4);
  final Color secondaryColor = const Color(0xFFe8dbf9); // Lighter shade
  final Color accentColor = const Color(0xFF9a6dd7);    // Deeper purple for contrast
  final Color textColor = const Color(0xFF4a3a5a);      // Dark purple for text

  @override
  void initState() {
    super.initState();
    _fetchAssignedWorkers();
  }

  Future<void> _fetchAssignedWorkers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Authentication token not found';
        });
        return;
      }

      final response = await DioInstance.getRequest(
        '/api/customers/get-assigned-workers/${widget.jobCardId}',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response != null && response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _workers = response.data['assignedMechanics'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = response?.data['message'] ?? 'Failed to load assigned workers';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Assigned Team',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: textColor,
            fontSize: 20,
          ),
        ),
        backgroundColor: primaryColor.withOpacity(0.95),
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textColor),
            onPressed: _fetchAssignedWorkers,
          ),
        ],
      ),
      backgroundColor: secondaryColor.withOpacity(0.3),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading team members...',
              style: GoogleFonts.poppins(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    if (_workers.isEmpty) {
      return _buildEmptyState();
    }

    return _buildWorkersList();
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[300], size: 60),
            const SizedBox(height: 16),
            Text(
              'Error Loading Team Members',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchAssignedWorkers,
              icon: const Icon(Icons.refresh),
              label: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No Team Members Assigned',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'There are currently no workers assigned to this job card.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkersList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 24),
      itemCount: _workers.length,
      itemBuilder: (context, index) {
        final worker = _workers[index];
        return _buildWorkerCard(worker, index);
      },
    );
  }

  Widget _buildWorkerCard(dynamic worker, int index) {
    // Alternate card background colors for visual separation
    final bool isEven = index % 2 == 0;
    final cardColor = isEven
        ? Colors.white
        : secondaryColor.withOpacity(0.3);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Could add detail view or contact action here
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAvatar(worker),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        worker['name'] ?? 'Unknown',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        worker['role'] ?? 'Team Member',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRatingBar(worker['rating']),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.phone_outlined,
                        color: accentColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.message_outlined,
                        color: accentColor,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(dynamic worker) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: primaryColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 32,
        backgroundColor: secondaryColor,
        backgroundImage: worker['profilePicUrl'] != null &&
            worker['profilePicUrl'].toString().isNotEmpty
            ? NetworkImage(worker['profilePicUrl'])
            : null,
        child: worker['profilePicUrl'] == null ||
            worker['profilePicUrl'].toString().isEmpty
            ? Text(
          worker['name'] != null && worker['name'].isNotEmpty
              ? worker['name'][0].toUpperCase()
              : '?',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        )
            : null,
      ),
    );
  }

  Widget _buildRatingBar(dynamic rating) {
    // Convert rating to a number or use default
    final double ratingValue = rating != null
        ? double.tryParse(rating.toString()) ?? 0.0
        : 0.0;

    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < ratingValue.floor()
                  ? Icons.star
                  : index < ratingValue
                  ? Icons.star_half
                  : Icons.star_border,
              size: 18,
              color: Colors.amber[700],
            );
          }),
        ),
        const SizedBox(width: 6),
        Text(
          ratingValue > 0 ? ratingValue.toStringAsFixed(1) : 'N/A',
          style: GoogleFonts.poppins(
            color: Colors.grey[800],
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}