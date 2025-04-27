import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sdp_app/utils/DioInstance.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Ratingpage extends StatefulWidget {
  final String jobCardId;

  const Ratingpage({super.key, required this.jobCardId});

  @override
  State<Ratingpage> createState() => _RatingpageState();
}

class _RatingpageState extends State<Ratingpage> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _assignedMechanics = [];
  Map<String, int> _ratings = {};
  String? _errorMessage;

  // Modern color scheme (matching your existing app)
  final Color primaryColor = Color(0xFF3D5AF1);
  final Color accentColor = Color(0xFF22B07D);
  final Color backgroundColor = Color(0xFFF8F9FD);
  final Color textDarkColor = Color(0xFF1A2151);
  final Color textLightColor = Color(0xFF8B92A8);
  final Color surfaceColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _fetchAssignedMechanics();
  }

  Future<void> _fetchAssignedMechanics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        _showError("Authentication failed. Please log in again.");
        return;
      }

      final Response response = await DioInstance.dio.get(
        "/api/customers/get-assigned-workers/${widget.jobCardId}",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success']) {
        final mechanicsData = response.data['assignedMechanics'] as List;

        setState(() {
          _assignedMechanics = mechanicsData.map((mechanic) => mechanic as Map<String, dynamic>).toList();

          // Initialize all ratings to 0 (unrated)
          for (var mechanic in _assignedMechanics) {
            _ratings[mechanic['employeeId'].toString()] = 0;
          }

          _isLoading = false;
        });
      } else {
        _showError(response.data['message'] ?? 'Failed to load mechanics');
      }
    } on DioException catch (e) {
      _showError(e.response?.data['message'] ?? "Failed to fetch assigned mechanics");
    } catch (e) {
      _showError("An unexpected error occurred: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitRating(String mechanicId, int rating) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        _showError("Authentication failed. Please log in again.");
        return;
      }

      final Response response = await DioInstance.dio.post(
        "/api/customers/update-mechanic-rating",
        data: {
          "jobCardId": widget.jobCardId,
          "mechanicId": mechanicId,
          "rating": rating
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success']) {
        _showSuccess('Rating submitted successfully');

        // Update the local state to reflect the new rating
        setState(() {
          for (var i = 0; i < _assignedMechanics.length; i++) {
            if (_assignedMechanics[i]['employeeId'].toString() == mechanicId) {
              _assignedMechanics[i]['rating'] = response.data['newRating'];
              break;
            }
          }
        });
      } else {
        _showError(response.data['message'] ?? 'Failed to submit rating');
      }
    } on DioException catch (e) {
      _showError(e.response?.data['message'] ?? "Failed to submit rating");
    } catch (e) {
      _showError("An unexpected error occurred: $e");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textDarkColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Rate Mechanics',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textDarkColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        )
            : _errorMessage != null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 60,
                color: Colors.red.shade300,
              ),
              SizedBox(height: 16),
              Text(
                'Error Loading Data',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textDarkColor,
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: textLightColor,
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _fetchAssignedMechanics,
                icon: Icon(Icons.refresh_rounded),
                label: Text(
                  'Try Again',
                  style: GoogleFonts.poppins(),
                ),
              ),
            ],
          ),
        )
            : _assignedMechanics.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off_rounded,
                size: 60,
                color: textLightColor,
              ),
              SizedBox(height: 16),
              Text(
                'No Mechanics Assigned',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textDarkColor,
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'There are no mechanics assigned to this job card.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: textLightColor,
                  ),
                ),
              ),
            ],
          ),
        )
            : SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Center(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: primaryColor,
                          size: 40,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Rate Service Quality',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textDarkColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your feedback helps improve our service',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: textLightColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Mechanics list
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _assignedMechanics.length,
                  itemBuilder: (context, index) {
                    final mechanic = _assignedMechanics[index];
                    final mechanicId = mechanic['employeeId'].toString();
                    final currentRating = _ratings[mechanicId] ?? 0;

                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 0,
                            offset: Offset(0, 2),
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
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: primaryColor.withOpacity(0.1),
                                  child: mechanic['profilePicUrl'] != null && mechanic['profilePicUrl'].toString().isNotEmpty
                                      ? ClipOval(
                                    child: Image.network(
                                      mechanic['profilePicUrl'],
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Icon(
                                        Icons.person,
                                        color: primaryColor,
                                        size: 24,
                                      ),
                                    ),
                                  )
                                      : Icon(
                                    Icons.person,
                                    color: primaryColor,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mechanic['name'] ?? 'Unknown Name',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: textDarkColor,
                                        ),
                                      ),
                                      Text(
                                        mechanic['role'] ?? 'Mechanic',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: textLightColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        (mechanic['rating']?.toString() ?? 'N/A'),
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: textDarkColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Rate this mechanic:',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textDarkColor,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (starIndex) {
                                return GestureDetector(
                                  onTap: _isSubmitting ? null : () {
                                    setState(() {
                                      _ratings[mechanicId] = starIndex + 1;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Icon(
                                      starIndex < currentRating
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      color: starIndex < currentRating
                                          ? Colors.amber
                                          : Colors.grey,
                                      size: 36,
                                    ),
                                  ),
                                );
                              }),
                            ),
                            SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: currentRating > 0 ? primaryColor : Colors.grey.shade300,
                                  foregroundColor: Colors.white,
                                  elevation: currentRating > 0 ? 2 : 0,
                                  shadowColor: primaryColor.withOpacity(0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: (currentRating > 0 && !_isSubmitting)
                                    ? () => _submitRating(mechanicId, currentRating)
                                    : null,
                                child: _isSubmitting
                                    ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                                    : Text(
                                  "Submit Rating",
                                  style: GoogleFonts.poppins(
                                    color: currentRating > 0 ? Colors.white : textLightColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}