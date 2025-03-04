import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sdp_app/data.dart';
import 'package:sdp_app/data/customer/CustomerVehicle.dart';
import 'package:sdp_app/components/FleetItem.dart';
import 'package:sdp_app/pages/notificationscreen.dart';
import 'package:sdp_app/data/customer/CustomerData.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  List<Vehicle> vehicles = getVehicle();
  List<NavigationItem>navigationItems=getNavigationItems();
  NavigationItem ?selectedItem;
  Customer? customer;

  Future<void> _loadCustomerData() async {
    Customer? fetchedCustomer = await fetchCustomerData();
    if (fetchedCustomer != null) {
      setState(() {
        customer = fetchedCustomer;
      });
    } else {
      print("Failed to load customer data.");
    }
  }

  @override
  void initState(){
    super.initState();
    setState(() {
      selectedItem=navigationItems[0];
      _loadCustomerData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Hello,", style: GoogleFonts.poppins(
                            fontSize: 15.0,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          )),
                          Text(customer?.firstName ?? "Loading...", style: GoogleFonts.poppins(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          )),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 50.0,
                            width: 50.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: customer?.profilePicUrl != null && customer!.profilePicUrl.isNotEmpty
                                ? Image.network(customer!.profilePicUrl, fit: BoxFit.cover)
                                : Image.asset("images/profilepic.jpg", fit: BoxFit.cover),
                          ),
                          SizedBox(width: 10.0),
                          GestureDetector(
                            onTap:(){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>Notificationscreen()));
                            },
                            child: Container(
                              height: 50.0,
                              width: 50.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: Icon(
                                Icons.notifications,
                                size: 30.0,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Your Vehicles", style: GoogleFonts.poppins(fontSize: 28.0, fontWeight: FontWeight.w300)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: SizedBox(
                          height: 150.0,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: BouncingScrollPhysics(),
                            children: buildFleet(),
                          ),
                        ),
                      ),
                    ),
                    
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Our Services", style: GoogleFonts.poppins(fontSize: 28.0, fontWeight: FontWeight.w300)),
                    ),
                    SizedBox(height: 20.0),
          
                    // 2x2 Grid with GestureDetector
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: SizedBox(
                        height: 350, // Adjust height as needed
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.3, // Adjust for better layout
                          children: getGridItems().map((item) {
                            return GestureDetector(
                              onTap: () {
                                print("${item.text} tapped");
                              },
                              child: Material(
                                elevation: 5.0, // Elevation effect
                                borderRadius: BorderRadius.circular(8.0),
                                shadowColor: Colors.black54, // Shadow color
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(item.icon, size: 40.0, color: Colors.white), // Icon
                                      SizedBox(height: 8.0), // Spacing
                                      Text(
                                        item.text,
                                        style: GoogleFonts.inter(color: Colors.white, fontSize: 16.0,fontWeight: FontWeight.w600),
                                      ), // Text
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
          
          
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          height:80.0,
          decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(50.0),

        ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: buildNavBar(),
          ),
        ),
      ),
    );
  }

  List<Widget> buildFleet() {
    List<Widget> list = [];
    for (var i = 0; i < vehicles.length; i++) {
      list.add(FleetItem(vehicles[i], i));
    }
    return list;
  }
  List<Widget>buildNavBar(){
    List<Widget> list = [];
    for (var i = 0; i < navigationItems.length; i++) {
      list.add(buildNavigationItem(navigationItems[i]));
    }
    return list;
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
            // Background circle remains separate from the icon
            if (selectedItem == nav)
              Container(
                height: 50.0,
                width: 50.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selectedItem == nav ? Colors.white : Colors.red[400],
                ),
              ),
            // Icon changes color based on selection
            Icon(
              nav.iconData,
              color: selectedItem == nav ? Colors.red : Colors.white,
              size: 24.0,
            ),
          ],
        ),
      ),
    );
  }
}
