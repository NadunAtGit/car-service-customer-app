import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sdp_app/utils/DioInstance.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

class Breakdownservice extends StatefulWidget {
  const Breakdownservice({super.key});

  @override
  State<Breakdownservice> createState() => _BreakdownserviceState();
}

class _BreakdownserviceState extends State<Breakdownservice> {
  // Selected location
  LatLong? _selectedLocation;

  // Flag to track if location has been obtained
  bool _locationObtained = false;

  // Emergency contact number
  final String _emergencyNumber = "123-456-7890"; // Replace with actual number

  // Form controllers
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    setState(() {
      _isLoading = true;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled. Please enable them.')),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied')),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Permissions are granted, get current location
    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Get current position using Geolocator with timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      // Update selected location
      if (mounted) {
        setState(() {
          _selectedLocation = LatLong(
              position.latitude,
              position.longitude
          );
          _locationObtained = true;
          _isLoading = false;
        });
        print("Location obtained: ${position.latitude}, ${position.longitude}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get current location: ${e.toString()}')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _callEmergency() async {
    final Uri url = Uri.parse('tel:$_emergencyNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone call')),
        );
      }
    }
  }

  Future<void> _submitRequest() async {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on the map')),
      );
      return;
    }

    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? customerId = prefs.getString('customerId');

      if (token == null) {
        throw Exception("Authentication token is missing");
      }

      // Prepare request data
      final requestData = {
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'description': _descriptionController.text,
        'contactName': _nameController.text,
        'contactPhone': _phoneController.text,
        'customerId': customerId,
      };

      // Make API call using DioInstance
      final response = await DioInstance.postRequest(
        '/api/customers/breakdown/request',
        requestData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response != null && response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your request has been submitted. Help is on the way!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception("Failed to submit request");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Color scheme
    const Color primaryColor = Color(0xFFD9BAF4); // #d9baf4
    const Color backgroundColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Breakdown Service',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : (_selectedLocation == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Obtaining your location...",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getCurrentLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      )
          : Container(
        color: backgroundColor,
        child: Column(
          children: [
            // Map section
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: FlutterLocationPicker(
                    initZoom: 15,
                    minZoomLevel: 5,
                    maxZoomLevel: 18,
                    trackMyPosition: true,
                    initPosition: _selectedLocation,
                    searchBarBackgroundColor: Colors.white,
                    mapLanguage: 'en',
                    selectLocationButtonText: 'Confirm Location',
                    selectLocationButtonStyle: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(primaryColor),
                    ),
                    selectLocationButtonLeadingIcon: const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                    ),
                    showSearchBar: true,
                    showSelectLocationButton: false,
                    showCurrentLocationPointer: true,
                    showLocationController: true,
                    showZoomController: true,
                    markerIcon: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 50,
                    ),
                    onError: (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    },
                    onPicked: (pickedData) {
                      setState(() {
                        _selectedLocation = pickedData.latLong;
                      });
                    },
                    onChanged: (pickedData) {
                      setState(() {
                        _selectedLocation = pickedData.latLong;
                      });
                    },
                  ),
                ),
              ),
            ),

            // Emergency call button
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.phone, color: Colors.white),
                label: const Text(
                  'EMERGENCY CALL',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _callEmergency,
              ),
            ),

            // Form section
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contact Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD9BAF4),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Your Name',
                          prefixIcon: const Icon(Icons.person,
                              color: Color(0xFFD9BAF4)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFFD9BAF4), width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Your Phone Number',
                          prefixIcon: const Icon(Icons.phone_android,
                              color: Color(0xFFD9BAF4)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFFD9BAF4), width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Describe Your Problem (Optional)',
                          prefixIcon: const Icon(Icons.description,
                              color: Color(0xFFD9BAF4)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFFD9BAF4), width: 2),
                          ),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Submit button
            Container(
              margin: const EdgeInsets.all(16),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD9BAF4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'REQUEST ASSISTANCE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}