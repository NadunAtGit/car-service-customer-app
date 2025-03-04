import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:sdp_app/pages/homescreen.dart';
import 'package:sdp_app/utils/DioInstance.dart';
import 'package:sdp_app/utils/validations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _firstnameController = TextEditingController();
  TextEditingController _secondnameController = TextEditingController();
  TextEditingController _telephoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmpwController = TextEditingController();

  bool _isLoading = false;
  bool _isObscured = true; // Password visibility toggle
  File? _imageFile; // Store selected image

  // Function to pick an image
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
        "/api/admin/upload-image/customerpics",
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

  Future<void> _signup() async {
    if (_validateInputs() == false) return;

    setState(() => _isLoading = true);

    try {
      String? imageUrl = await _uploadImage(_imageFile!);
      if (imageUrl == null) {
        _showError("Image upload failed. Please try again.");
        return;
      }

      Response response = await DioInstance.dio.post(
        "/api/customers/customer-signup",
        data: {
          "FirstName": _firstnameController.text.trim(),
          "SecondName": _secondnameController.text.trim(),
          "Telephone": _telephoneController.text.trim(),
          "Email": _emailController.text.trim(),
          "Password": _passwordController.text.trim(),
          "Username": _usernameController.text.trim(),
          "profilePicUrl": imageUrl,
        },
      );

      print("Signup Response: \${response.data}");

      if (response.statusCode == 200 && response.data['success']) {
        String token = response.data['accessToken'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Homescreen()),
        );
      } else {
        _showError(response.data['message']);
      }
    } on DioException catch (e) {
      print("Signup Error: ${e.response != null ? e.response!.data.toString() : e.message}");
      _showError(e.response?.data['message'] ?? "Signup failed. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _validateInputs() {
    if (_firstnameController.text.trim().isEmpty ||
        _secondnameController.text.trim().isEmpty ||
        _telephoneController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _usernameController.text.trim().isEmpty ||
        _confirmpwController.text.trim().isEmpty) {
      _showError("All fields are required.");
      return false;
    }
    if (_passwordController.text != _confirmpwController.text) {
      _showError("Passwords do not match.");
      return false;
    }
    if (_imageFile == null) {
      _showError("Please select a profile image.");
      return false;
    }
    return true;
  }







  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 130.0,
                    width: 130.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                      image: _imageFile != null
                          ? DecorationImage(
                        image: FileImage(_imageFile!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: _imageFile == null
                        ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 34.0),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: "Username",
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0)),
                    suffixIcon: const Icon(Icons.supervised_user_circle, size: 24, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 14.0),
                TextField(
                  controller: _firstnameController,
                  decoration: InputDecoration(
                    hintText: "Firstname",
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0)),
                  ),
                ),
                const SizedBox(height: 14.0),
                TextField(
                  controller: _secondnameController,
                  decoration: InputDecoration(
                    hintText: "Secondname",
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0)),
                  ),
                ),
                const SizedBox(height: 14.0),
                TextField(
                  controller: _telephoneController,
                  decoration: InputDecoration(
                    hintText: "Telephone",
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0)),
                    suffixIcon: const Icon(Icons.phone_android_outlined, size: 24, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 14.0),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Email",
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0)),
                    suffixIcon: const Icon(Icons.email_outlined, size: 24, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 14.0),
                TextField(
                  controller: _passwordController,
                  obscureText: _isObscured,
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0)),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility, size: 24, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14.0),
                TextField(
                  controller: _confirmpwController,
                  obscureText: _isObscured,
                  decoration: InputDecoration(
                    hintText: "Reconfirm Password",
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0)),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility, size: 24, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: _signup, // Call _signup function here
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Signup",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

