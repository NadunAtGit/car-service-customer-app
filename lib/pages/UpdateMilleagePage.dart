import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sdp_app/data/customer/CustomerVehicle.dart';
import 'package:sdp_app/utils/DioInstance.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateMileagePage extends StatefulWidget {
  final Vehicle vehicle;

  const UpdateMileagePage({Key? key, required this.vehicle}) : super(key: key);

  @override
  _UpdateMileagePageState createState() => _UpdateMileagePageState();
}

class _UpdateMileagePageState extends State<UpdateMileagePage> {
  final TextEditingController _mileageController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // Modern color scheme
  final Color primaryColor = Color(0xFF944EF8);
  final Color backgroundColor = Color(0xFFEAEAEA);
  final Color textDarkColor = Color(0xFF1A2151);
  final Color textLightColor = Color(0xFF8B92A8);
  final Color surfaceColor = Colors.white;

  @override
  void initState() {
    super.initState();
    // Pre-fill with current mileage if available
    if (widget.vehicle.currentMilleage != null) {
      _mileageController.text = widget.vehicle.currentMilleage.toString();
    }
  }

  Future<void> _updateMileage() async {
    // Validate input
    if (_mileageController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Please enter the current mileage";
      });
      return;
    }

    int? newMileage;
    try {
      newMileage = int.parse(_mileageController.text.trim());
      if (newMileage <= 0) {
        setState(() {
          _errorMessage = "Mileage must be greater than zero";
        });
        return;
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Please enter a valid number";
      });
      return;
    }

    // If current mileage exists, check that new mileage is greater
    if (widget.vehicle.currentMilleage != null &&
        newMileage <= widget.vehicle.currentMilleage!) {
      setState(() {
        _errorMessage = "New mileage must be greater than current mileage (${widget.vehicle.currentMilleage} km)";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Authentication failed. Please log in again.";
        });
        return;
      }

      // Make API call to update mileage
      Response response = await DioInstance.dio.put(
        "/api/customers/update-milleage/${widget.vehicle.vehicleNo}",
        data: {
          "CurrentMilleage": newMileage,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200 && response.data['success']) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Mileage updated successfully!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Return to previous screen after a short delay
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      } else {
        setState(() {
          _errorMessage = response.data['error'] ?? "Failed to update mileage";
        });
      }
    } on DioException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.response?.data['error'] ?? "Request failed. Please try again.";
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "An unexpected error occurred";
      });
    }
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
          'Update Mileage',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textDarkColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle info card
                _buildVehicleInfoCard(),

                SizedBox(height: 24),

                // Current mileage display
                if (widget.vehicle.currentMilleage != null) ...[
                  _buildInfoLabel("Current Mileage"),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.speed, color: primaryColor),
                        SizedBox(width: 12),
                        Text(
                          "${widget.vehicle.currentMilleage} km",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                ],

                // New mileage input
                _buildInfoLabel("New Mileage (km)"),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: surfaceColor,
                    border: Border.all(
                      color: _errorMessage != null ? Colors.red : Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _mileageController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: textDarkColor,
                    ),
                    decoration: InputDecoration(
                      hintText: "Enter new mileage",
                      hintStyle: GoogleFonts.poppins(
                        color: textLightColor,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.speed,
                        color: primaryColor,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),

                // Error message
                if (_errorMessage != null) ...[
                  SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],

                SizedBox(height: 32),

                // Update button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: primaryColor.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isLoading ? null : _updateMileage,
                    child: _isLoading
                        ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                        : Text(
                      "Update Mileage",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            clipBehavior: Clip.hardEdge,
            child: widget.vehicle.picUrl.isNotEmpty
                ? Image.network(
              widget.vehicle.picUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.directions_car,
                size: 40,
                color: Colors.grey,
              ),
            )
                : Icon(
              Icons.directions_car,
              size: 40,
              color: Colors.grey,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.vehicle.model}",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textDarkColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "${widget.vehicle.type}",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: textLightColor,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.vehicle.vehicleNo,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textDarkColor,
      ),
    );
  }
}
