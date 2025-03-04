import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async'; // Import for Future.delayed
import 'package:google_fonts/google_fonts.dart';
import 'package:sdp_app/pages/loginscreen.dart';

class Spalshscreen extends StatefulWidget {
  const Spalshscreen({super.key});

  @override
  _SpalshscreenState createState() => _SpalshscreenState();
}

class _SpalshscreenState extends State<Spalshscreen> {
  @override
  void initState() {
    super.initState();
    // Delay for 5 seconds before navigating to LoginScreen
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Loginscreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.red, // Set status bar color
          statusBarIconBrightness: Brightness.light,
        ),
        backgroundColor: Colors.white, // Keep the app bar background white
        elevation: 0, // Remove shadow
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.scale(
              scale: 0.7, // Adjust scale factor
              child: Image.asset("images/logo.png", fit: BoxFit.cover),
            ),
            const SizedBox(height: 90.0),
            Column(
              children: [
                const Text(
                  "Designed & Developed by",
                  style: TextStyle(fontWeight: FontWeight.w100, color: Colors.grey),
                ),
                Text(
                  "Nadun Sooriyaarachchi",
                  style: GoogleFonts.greatVibes(
                    fontWeight: FontWeight.w400,
                    fontSize: 24.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
