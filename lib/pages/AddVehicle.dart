import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
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
  final Color primaryColor = Color(0xFF944EF8);
  final Color backgroundColor = Color(0xFFEAEAEA);

  final TextEditingController _regNumController = TextEditingController();
  final TextEditingController _makeController = TextEditingController();

  Future<void> _pickImage() async {
    try {
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Choose Image Source',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _imageSourceOption(
                            context,
                            Icons.camera_alt,
                            'Camera',
                            ImageSource.camera,
                          ),
                          _imageSourceOption(
                            context,
                            Icons.photo_library,
                            'Gallery',
                            ImageSource.gallery,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
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
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 30,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
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

      print("Image Upload Response: ${response.data.toString()}");
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
          "VehiclePicUrl": imageUrl
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      print("Add vehicle response: ${response.data}");

      if (response.statusCode == 201 && response.data['success']) {
        // Show success message before navigating
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Vehicle added successfully!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Delay navigation to show snackbar
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
      print("Error: ${e.response?.data.toString() ?? e.message}");
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
        backgroundColor: Colors.red,
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
      body: Stack(
        children: [
          // Background image or pattern
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withOpacity(0.3),
                  backgroundColor,
                ],
              ),
            ),
          ),

          // Abstract circle decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.2),
              ),
            ),
          ),

          Positioned(
            top: 50,
            left: -50,
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.1),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: primaryColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Add Vehicle',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // Image picker
                          SizedBox(height: 20),
                          Text(
                            'Upload Vehicle Image',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 20),
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              height: 200,
                              width: 200, // Make width equal to height for a perfect circle
                              decoration: BoxDecoration(
                                shape: BoxShape.circle, // Change from borderRadius to shape: BoxShape.circle
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: ClipOval( // Replace ClipRRect with ClipOval
                                child: _imageFile != null
                                    ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.file(
                                      _imageFile!,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      right: 10,
                                      top: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.8),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.edit,
                                          color: primaryColor,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                                    : Container(
                                  color: Colors.white,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(
                                        Icons.directions_car,
                                        size: 70,
                                        color: Colors.grey.withOpacity(0.3),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                            padding: EdgeInsets.symmetric(vertical: 16),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                                colors: [
                                                  primaryColor.withOpacity(0.7),
                                                  primaryColor.withOpacity(0.0),
                                                ],
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Flexible(
                                                  child: Icon(
                                                    Icons.add_photo_alternate,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                ),
                                                SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    'Add Photo',
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 12,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            )
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 30),

                          // Form fields
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white.withOpacity(0.8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Vehicle Details',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 20),

                                      // Registration Number
                                      Text(
                                        'Registration Number',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.grey.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: TextField(
                                          controller: _regNumController,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: "e.g., KA-01-AB-1234",
                                            hintStyle: GoogleFonts.poppins(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                            prefixIcon: Icon(
                                              Icons.directions_car,
                                              color: primaryColor,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20),

                                      // Make & Model
                                      Text(
                                        'Make & Model',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.grey.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: TextField(
                                          controller: _makeController,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: "e.g., Honda Civic",
                                            hintStyle: GoogleFonts.poppins(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                            prefixIcon: Icon(
                                              Icons.car_rental,
                                              color: primaryColor,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20),

                                      // Vehicle Type
                                      Text(
                                        'Vehicle Type',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: primaryColor,
                                            onSurface: Colors.black87,
                                          ),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            color: Colors.white,
                                            border: Border.all(
                                              color: Colors.grey.withOpacity(0.3),
                                              width: 1,
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
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 30),

                          // Submit button
                          Container(
                            width: double.infinity,
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor,
                                  Color(0xFF7E3BD0), // Darker shade of primary color
                                ],
                              ),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _isLoading ? null : _addVehicle,
                              child: _isLoading
                                  ? SizedBox(
                                height: 25,
                                width: 25,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}