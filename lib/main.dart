import 'package:flutter/material.dart';
import 'package:sdp_app/pages/spalshscreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sdp_app/pages/loginscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car service center management system',
      theme: ThemeData(

          primarySwatch: Colors.red,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: GoogleFonts.mulishTextTheme()
      ),
      debugShowCheckedModeBanner: false,
      home: const Spalshscreen(),
    );
  }
}


