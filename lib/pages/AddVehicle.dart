import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sdp_app/components/VehicleTypeDropdown.dart';
import 'package:sdp_app/utils/DioInstance.dart';
import 'package:sdp_app/utils/validations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sdp_app/pages/homescreen.dart';
import 'package:sdp_app/pages/Mainpage.dart';

class Addvehicle extends StatefulWidget {
  const Addvehicle({super.key});

  @override
  State<Addvehicle> createState() => _AddvehicleState();
}

class _AddvehicleState extends State<Addvehicle> {
  File? _imageFile;
  bool _isLoading = false;
  String? _selectedVehicleType;

  // Modern color scheme
  final Color primaryColor = Color(0xFF3D5AF1);
  final Color accentColor = Color(0xFF22B07D);
  final Color backgroundColor = Color(0xFFF8F9FD);
  final Color textDarkColor = Color(0xFF1A2151);
  final Color textLightColor = Color(0xFF8B92A8);
  final Color surfaceColor = Colors.white;

  final TextEditingController _regNumController = TextEditingController();
  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();

  Future<void> _pickImage() async {
    try {
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Choose Image Source',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textDarkColor,
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _imageSourceOption(
                        context,
                        Icons.camera_alt_rounded,
                        'Camera',
                        ImageSource.camera,
                      ),
                      _imageSourceOption(
                        context,
                        Icons.photo_library_rounded,
                        'Gallery',
                        ImageSource.gallery,
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      );

      if (source != null) {
        final pickedFile = await ImagePicker().pickImage(source: source);
        if (pickedFile != null) {
          setState(() => _imageFile = File(pickedFile.path));
        }
      }
    } catch (e) {
      _showError("Error picking image: $e");
    }
  }

  Widget _imageSourceOption(
      BuildContext context,
      IconData icon,
      String label,
      ImageSource source,
      ) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, source),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 28,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textDarkColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      Response response = await DioInstance.dio.post(
        "/api/admin/upload-image/cars",
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );

      return response.statusCode == 201 ? response.data["imageUrl"] : null;
    } catch (e) {
      _showError("Image upload error: $e");
      return null;
    }
  }

  Future<void> _addVehicle() async {
    // Form validation
    if (_regNumController.text.trim().isEmpty) {
      _showError("Please enter a registration number");
      return;
    }

    if (_makeController.text.trim().isEmpty) {
      _showError("Please enter vehicle make and model");
      return;
    }

    if (_selectedVehicleType == null) {
      _showError("Please select a vehicle type");
      return;
    }

    if (_imageFile == null) {
      _showError("Please select a vehicle image");
      return;
    }

    // Validate mileage input
    final mileageText = _mileageController.text.trim();
    if (mileageText.isEmpty) {
      _showError("Please enter current mileage");
      return;
    }

    // Parse mileage to ensure it's a valid number
    int? mileage;
    try {
      mileage = int.parse(mileageText);
      if (mileage < 0) {
        _showError("Mileage cannot be negative");
        return;
      }
    } catch (e) {
      _showError("Please enter a valid mileage number");
      return;
    }

    setState(() => _isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        _showError("Authentication failed. Please log in again.");
        return;
      }

      String? imageUrl = await _uploadImage(_imageFile!);
      if (imageUrl == null) {
        _showError("Image upload failed. Please try again.");
        return;
      }

      Response response = await DioInstance.dio.post(
        "/api/customers/add-vehicle",
        data: {
          "VehicleNo": _regNumController.text.trim(),
          "Model": _makeController.text.trim(),
          "Type": _selectedVehicleType,
          "VehiclePicUrl": imageUrl,
          "CurrentMilleage": int.parse(_mileageController.text.trim())
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 201 && response.data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Vehicle added successfully!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Mainpage()),
          );
        });
      } else {
        _showError(response.data['message']);
      }
    } on DioException catch (e) {
      _showError(e.response?.data['message'] ?? "Request failed. Please try again.");
    } finally {
      setState(() => _isLoading = false);
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
          'Add Vehicle',
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
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modern section headings with icons
                SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.photo_camera_outlined, color: primaryColor),
                    SizedBox(width: 8),
                    Text(
                      'Vehicle Image',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textDarkColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Modern image picker
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: surfaceColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _imageFile != null
                            ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0),
                                    Colors.black.withOpacity(0.4),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.edit_rounded,
                                  color: primaryColor,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        )
                            : Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 90,
                              backgroundColor: Colors.grey.withOpacity(0.1),
                              child: Icon(
                                Icons.directions_car_outlined,
                                size: 60,
                                color: textLightColor,
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Add Photo',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 32),

                // Vehicle details section
                Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: primaryColor),
                    SizedBox(width: 8),
                    Text(
                      'Vehicle Details',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textDarkColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Modern form fields
                _buildFormLabel('Registration Number'),
                SizedBox(height: 8),
                _buildTextField(
                  controller: _regNumController,
                  hintText: "e.g., KA-01-AB-1234",
                  prefixIcon: Icons.directions_car_filled_outlined,
                ),

                SizedBox(height: 20),

                _buildFormLabel('Make & Model'),
                SizedBox(height: 8),
                _buildTextField(
                  controller: _makeController,
                  hintText: "e.g., Honda Civic",
                  prefixIcon: Icons.car_rental_outlined,
                ),

                SizedBox(height: 20),

                _buildFormLabel('Current Mileage (km)'),
                SizedBox(height: 8),
                _buildTextField(
                  controller: _mileageController,
                  hintText: "e.g., 15000",
                  prefixIcon: Icons.speed_outlined,
                  keyboardType: TextInputType.number,
                ),

                SizedBox(height: 20),

                _buildFormLabel('Vehicle Type'),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: surfaceColor,
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
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
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: primaryColor,
                        onSurface: textDarkColor,
                      ),
                    ),
                    child: VehicleTypeDropdown(
                      onChanged: (String? selectedType) {
                        setState(() {
                          _selectedVehicleType = selectedType;
                        });
                      },
                    ),
                  ),
                ),

                SizedBox(height: 40),
                // Submit button
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
                    onPressed: _isLoading ? null : _addVehicle,
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
                      "Add Vehicle",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textDarkColor,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: surfaceColor,
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
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
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: textDarkColor,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: textLightColor,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: primaryColor,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
