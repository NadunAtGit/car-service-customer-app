import 'package:flutter/material.dart';
import 'package:sdp_app/data.dart'; // Import NavigationItem data

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  int _currentIndex = 0;
  late List<NavigationItem> _navigationItems;
  NavigationItem? selectedItem;

  @override
  void initState() {
    super.initState();
    _navigationItems = getNavigationItems();
    selectedItem = _navigationItems[_currentIndex];
  }

  Widget buildNavigationItem(NavigationItem nav) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedItem = nav;
          _currentIndex = _navigationItems.indexOf(nav);
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
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF944ef8),
                ),
              ),
            Icon(nav.iconData, color: Colors.white, size: 24.0),
          ],
        ),
      ),
    );
  }

  List<Widget> buildNavBar() {
    return _navigationItems.map((nav) => buildNavigationItem(nav)).toList();
  }

  Widget _buildBottomNavBar() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: 75.0,
        decoration: BoxDecoration(
          color: const Color(0xFFd1b6ed),
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: buildNavBar(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAEAEA),
      body: _navigationItems[_currentIndex].page,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}
