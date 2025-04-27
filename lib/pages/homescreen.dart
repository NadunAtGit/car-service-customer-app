import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sdp_app/data.dart';
import 'package:sdp_app/data/customer/CustomerVehicle.dart';
import 'package:sdp_app/components/FleetItem.dart';
import 'package:sdp_app/pages/UserDetailsPage.dart';
import 'package:sdp_app/pages/notificationscreen.dart';
import 'package:sdp_app/data/customer/CustomerData.dart';
import 'package:sdp_app/pages/AddVehicle.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sdp_app/utils/DioInstance.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sdp_app/components/NotFinishedStatus.dart';
import 'package:sdp_app/pages/UpdateMilleagePage.dart';

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
  final Color primaryColor = Color(0xFF944EF8);
  final Color backgroundColor = Color(0xFFEAEAEA);
  final Color cardColor = Color(0xFFf5f6ff);

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
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryColor,
          onRefresh: () async {
            await _loadCustomerData();
            await _loadVehicles();
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  NotFinishedStatus(),
                  SizedBox(
                    height: 10.0,
                  ),
                  _buildUpcomingServiceCard(),
                  _buildSectionTitle("Our Services"),
                  _buildServiceGrid(),
                  SizedBox(height: 20),
                  _buildSectionTitle("Your Vehicles"),
                  _buildVehicleCarousel(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Addvehicle())
          ).then((_) => _loadVehicles());
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildProfilePicture(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello,",
                    style: GoogleFonts.poppins(
                      fontSize: 16.0,
                      color: Colors.black54,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    customer?.firstName ?? "Loading...",
                    style: GoogleFonts.poppins(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildNotificationIcon(),
        ],
      ),
    );
  }

  Widget _buildProfilePicture() {
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserDetailsPage()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: Container(
          height: 50.0,
          width: 50.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5.0,
                offset: Offset(0, 2),
              )
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: customer?.profilePicUrl != null && customer!.profilePicUrl.isNotEmpty
              ? Image.network(customer!.profilePicUrl, fit: BoxFit.cover)
              : Image.asset("images/profilepic.jpg", fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationScreen()));
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5.0,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Icon(
              Icons.notifications_outlined,
              size: 26.0,
              color: primaryColor,
            ),
            Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 22.0,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildServiceStatusCard() {
    return Container(
      height: 110,
      margin: EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.build_outlined,
                size: 32.0,
                color: primaryColor,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Current Service Status",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "In Progress",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Est. completion: 2:30 PM",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black45,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingServiceCard() {
    return Container(
      // Removed fixed height constraint to allow content to determine the size
      margin: EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: cardColor.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Stack(
          children: [
            // Background gradient for more visual appeal
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cardColor.withOpacity(0.8),
                    cardColor,
                  ],
                ),
              ),
            ),
            // Car image in the corner
            Positioned(
              right: -30,
              bottom: 40,
              child: Container(
                height: 180.0,
                width: 180.0,
                // child: Image.asset(
                //   'images/wrx.jpg',
                //   fit: BoxFit.cover,
                // ),
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // Changed to remove mainAxisAlignment and mainAxisSize properties
                // which were causing layout issues
                children: [
                  // Mileage update importance section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Animated badge for daily mileage
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(milliseconds: 800),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.trending_up,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Daily Tracker",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Track Mileage Daily",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "For accurate service schedules & maintenance alerts",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // Added some vertical spacing between content sections
                  SizedBox(height: 16),
                  // Interactive elements row
                  Row(
                    children: [
                      // Quick update button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to update mileage page if a vehicle is selected
                            if (vehicles.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdateMileagePage(vehicle: vehicles[0]),
                                ),
                              ).then((_) => _loadVehicles());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Animated icon for attention
                              TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: Duration(milliseconds: 1000),
                                builder: (context, value, child) {
                                  return Transform.rotate(
                                    angle: value * 0.2 * (value < 0.5 ? value : 1 - value) * 2,
                                    child: child,
                                  );
                                },
                                child: Icon(Icons.speed, size: 16),
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Update Now",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      // Info button with tooltip
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {
                            // Show dialog explaining importance of daily mileage updates
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Why Update Daily?"),
                                content: Text(
                                  "Regular mileage updates help us provide accurate maintenance schedules, fuel efficiency tracking, and timely service reminders to keep your vehicle in top condition.",
                                  style: GoogleFonts.poppins(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Got it"),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.info_outline,
                            color: primaryColor,
                            size: 20,
                          ),
                          tooltip: "Why update daily?",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Progress indicator showing update streaks or consistency
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Circular progress indicator showing update streak
                    Center(
                      child: SizedBox(
                        height: 36,
                        width: 36,
                        child: CircularProgressIndicator(
                          value: 0.7, // Example: 70% consistent with daily updates
                          strokeWidth: 4,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                          backgroundColor: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                    ),
                    // Day count in the center
                    Center(
                      child: Text(
                        "7",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceGrid() {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: getGridItems(context).length,
        itemBuilder: (context, index) {
          final item = getGridItems(context)[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => item.destination),
                );
              },
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8.0,
                      spreadRadius: 1.0,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.icon,
                        size: 26.0,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      item.text,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVehicleCarousel() {
    if (isLoadingVehicles) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      );
    }

    if (vehicles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(Icons.directions_car_outlined, size: 48, color: Colors.black45),
              SizedBox(height: 12),
              Text(
                "No vehicles found",
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.black45),
              ),
              SizedBox(height: 8),
              Text(
                "Add your first vehicle by tapping the + button",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black38),
              ),
            ],
          ),
        ),
      );
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        enlargeCenterPage: true,
        autoPlay: vehicles.length > 1,
        aspectRatio: 16/9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: vehicles.length > 1,
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        viewportFraction: 0.8,
      ),
      items: vehicles.map((vehicle) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8.0,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Stack(
                  children: [
                    // Background image
                    Positioned.fill(
                      child: vehicle.picUrl != null && vehicle.picUrl.isNotEmpty
                          ? Image.network(vehicle.picUrl, fit: BoxFit.cover)
                          : Image.asset("images/car_placeholder.jpg", fit: BoxFit.cover),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    // Vehicle info
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicle.type + " " + vehicle.model,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  vehicle.vehicleNo,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 14.0,
                                  ),
                                ),
                                Spacer(),
                                // Interactive mileage display that also serves as the update button
                                _buildMileageUpdate(context, vehicle),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Status label
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_graph,
                              size: 12,
                              color: Colors.green,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Good",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  // New method to create a beautiful interactive mileage widget
  Widget _buildMileageUpdate(BuildContext context, Vehicle vehicle) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdateMileagePage(vehicle: vehicle),
          ),
        ).then((_) => _loadVehicles());
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor.withOpacity(0.8), primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated odometer icon
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(milliseconds: 800),
              builder: (context, double value, child) {
                return Transform.rotate(
                  angle: value * 0.2,
                  child: child,
                );
              },
              child: Icon(
                Icons.speed,
                size: 16,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 6),
            // Current mileage with pulse animation on load
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.8, end: 1),
              duration: Duration(milliseconds: 1200),
              curve: Curves.elasticOut,
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Text(
                vehicle.currentMilleage != null
                    ? '${vehicle.currentMilleage} km'
                    : 'Add',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 4),
            // Edit icon with subtle animation
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(milliseconds: 600),
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: Icon(
                Icons.edit,
                size: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: EdgeInsets.all(16.0),
      height: 65.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8.0,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, "Home", true),
          _buildNavItem(Icons.history, "History", false),
          _buildNavItem(Icons.directions_car_outlined, "Vehicles", false),
          _buildNavItem(Icons.person_outline, "Profile", false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        // Handle navigation
      },
      child: Container(
        width: 70.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.black45,
                size: 24.0,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? primaryColor : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}