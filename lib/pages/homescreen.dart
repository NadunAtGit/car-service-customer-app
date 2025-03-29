import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sdp_app/data.dart';
import 'package:sdp_app/data/customer/CustomerVehicle.dart';
import 'package:sdp_app/components/FleetItem.dart';
import 'package:sdp_app/pages/notificationscreen.dart';
import 'package:sdp_app/data/customer/CustomerData.dart';
import 'package:sdp_app/pages/AddVehicle.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  List<NavigationItem> navigationItems = getNavigationItems();
  NavigationItem? selectedItem;
  Customer? customer;
  List<Vehicle> vehicles = [];
  bool isLoadingVehicles = true;

  Future<void> _loadCustomerData() async {
    Customer? fetchedCustomer = await fetchCustomerData();
    setState(() {
      customer = fetchedCustomer;
    });
  }

  Future<void> _loadVehicles() async {
    List<Vehicle> fetchedVehicles = await getVehicle();
    setState(() {
      vehicles = fetchedVehicles;
      isLoadingVehicles = false;
    });
  }

  @override
  void initState() {
    super.initState();
    selectedItem = navigationItems[0];
    _loadCustomerData();
    _loadVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAEAEA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildGlassCard(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Our Services",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 30,
                  ),
                ),
              ),
              _buildServiceGrid(),
            ],
          ),
        ),
      ),
      // Fixing the bottom navbar
    );

  }

  Widget _buildHeader() {
    return Container(

      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildProfilePicture(),
                    Text(
                      "Hello, ",
                      style: GoogleFonts.poppins(
                        fontSize: 20.0,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      customer?.firstName ?? "Loading...",
                      style: GoogleFonts.poppins(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ],
                )

              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                SizedBox(width: 10.0),
                _buildNotificationIcon(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0), // Add 10px right margin
      child: Container(
        height: 50.0,
        width: 50.0,
        decoration: BoxDecoration(shape: BoxShape.circle),
        clipBehavior: Clip.hardEdge,
        child: customer?.profilePicUrl != null && customer!.profilePicUrl.isNotEmpty
            ? Image.network(customer!.profilePicUrl, fit: BoxFit.cover)
            : Image.asset("images/profilepic.jpg", fit: BoxFit.cover),
      ),
    );
  }


  Widget _buildNotificationIcon() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Notificationscreen()));
      },
      child: Icon(
        Icons.notifications_outlined, // Use the outlined icon
        size: 30.0,
        color: Color(0xFF944EF8), // Set the color to #944EF8
      ),
    );
  }



  Widget _buildTitle(String title, Widget? destination) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: destination != null
            ? () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
        }
            : null,
        child: Text(title, style: GoogleFonts.poppins(fontSize: 28.0, fontWeight: FontWeight.w300)),
      ),
    );
  }

  Widget _buildServiceGrid() {
    return SizedBox(
      height: 100, // Adjust height for single row of cards
      child: ListView(
        scrollDirection: Axis.horizontal, // Makes it horizontal instead of vertical grid
        children: getGridItems(context).map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => item.destination),
                );
              },
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(25.0),
                shadowColor: Colors.black54,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F6FF), // Set background color to #F5F6FF
                    borderRadius: BorderRadius.circular(20.0),
                     // Set border color to #944EF8
                  ),
                  width: 80, // Adjust the width of each card
                  margin: EdgeInsets.symmetric(horizontal: 8.0), // Add margin between cards
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: 40.0,
                        color: Color(0xFF944EF8), // Set icon color to #944EF8
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        item.text,
                        style: GoogleFonts.inter(
                          color: Color(0xFF944EF8), // Set text color to #944EF8
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }


  Widget _buildBottomNavBar() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: 80.0,
        decoration: BoxDecoration(color: Color(0xFFd1b6ed), borderRadius: BorderRadius.circular(50.0)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: buildNavBar(),
        ),
      ),
    );
  }

  Widget _buildGlassCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 200,
        margin: EdgeInsets.only(top: 30.0), // Add margin to separate from header
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Color(0xFFf5f6ff).withOpacity(0.9), // Semi-transparent background for glass effect

        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Axios has Reached:",
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      "12,000 km",
                      style: TextStyle(fontSize: 30),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    // Full-width ElevatedButton with custom color and text
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF944EF8), // Set button color to #944EF8
                          // Full width button with height 50
                        ),
                        child: Text(
                          "Appoint",
                          style: TextStyle(
                            fontSize: 18, // Adjust the font size as needed
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                          ),
                        ),
                      ),
                    ),
                  ],
                ),



            ),
            Container(
              height: 150.0, // Set the height as needed
              width: 150.0, // Set the width as needed
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0), // Rounded corners
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0), // Ensure the image is clipped with rounded corners
                child: Image.asset(
                  'images/wrx.jpg', // Replace with your image path
                  fit: BoxFit.cover, // Makes the image cover the entire container
                ),
              ),
            )

          ],
        ),

      ),
    );
  }

  List<Widget> buildFleet() {
    return vehicles.map((vehicle) => FleetItem(vehicle, vehicles.indexOf(vehicle))).toList();
  }

  List<Widget> buildNavBar() {
    return navigationItems.map((nav) => buildNavigationItem(nav)).toList();
  }

  Widget buildNavigationItem(NavigationItem nav) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedItem = nav;
        });
      },
      child: Container(
        width: 50.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (selectedItem == nav)
              Container(
                height: 50.0,
                width: 50.0,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xFF944ef8)),
              ),
            Icon(nav.iconData, color: selectedItem == nav ? Colors.white : Colors.white, size: 24.0),
          ],
        ),
      ),
    );
  }
}
