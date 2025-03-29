import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
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

  TextEditingController _regNumController = TextEditingController();
  TextEditingController _makeController = TextEditingController();


  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
      }
    } catch (e) {
      _showError("Error picking image: \$e");
    }
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
      _showError("Image upload error: \$e");
      return null;
    }
  }

  Future<void> _addVehicle() async {
    setState(() => _isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token'); // Retrieve the token

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
            "Authorization": "Bearer $token", // Attach token in headers
            "Content-Type": "application/json",
          },
        ),
      );

      print("Add vehicle response: ${response.data}");

      if (response.statusCode == 201 && response.data['success']) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Mainpage()),
        );
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
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 80.0),
              child: Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 180.0,  // Keeping the larger size from the first container
                    width: 180.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _imageFile == null ? Colors.red : Colors.grey[300], // Red if no image, grey if image exists
                      image: _imageFile != null
                          ? DecorationImage(
                        image: FileImage(_imageFile!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: _imageFile == null
                        ? const Icon(Icons.camera_alt, size: 50, color: Colors.white) // Bigger icon for larger container
                        : null,
                  ),
                ),

              ),
            ),

            Expanded(
              child: Container(

                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(40.0),topRight: Radius.circular(40.0))
                ),

                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),

                  child: Column(
                    children: [
                      SizedBox(height: 50.0,),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(15.0))
                        ),

                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: TextField(
                            controller: _regNumController,
                            decoration: InputDecoration(
                              hintText: "Registration Number",
                              hintStyle: TextStyle(
                                color: Colors.black,

                              ),
                              border: InputBorder.none
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30.0,),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(15.0))
                        ),

                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: TextField(
                            controller: _makeController,
                            decoration: InputDecoration(
                                hintText: "Make & Model",
                                hintStyle: TextStyle(
                                  color: Colors.black,

                                ),
                                border: InputBorder.none
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30.0,),
                      VehicleTypeDropdown(
                        onChanged: (String? selectedType) {
                          setState(() {
                            _selectedVehicleType = selectedType;
                          });
                        },
                      ),
                      SizedBox(height: 60.0,),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: (){
                          _addVehicle();
                        },
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.red)
                            : const Text("Login", style: TextStyle(color: Colors.red, fontSize: 18,fontWeight: FontWeight.bold)),
                      ),



                    ],
                  ),
                ),
              ),
            )
          ],
        ))
    );
  }
}
