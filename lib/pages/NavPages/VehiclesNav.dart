import 'package:flutter/material.dart';
import 'package:sdp_app/pages/AddVehicle.dart';
import 'package:sdp_app/data/customer/CustomerVehicle.dart';
import 'package:sdp_app/pages/GridPages/BookAppointment.dart';

import '../VehicleDetails.dart';

class Vehiclesnav extends StatefulWidget {
  const Vehiclesnav({super.key});

  @override
  State<Vehiclesnav> createState() => _VehiclesnavState();
}

class _VehiclesnavState extends State<Vehiclesnav> {
  List<Vehicle> vehicles = [];
  bool isLoadingVehicles = true;

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
    _loadVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 80,
              collapsedHeight: 60,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'My Garage',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF944EF8),
                        const Color(0xFFd9baf4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: isLoadingVehicles
            ? const Center(child: CircularProgressIndicator())
            : vehicles.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
          onRefresh: _loadVehicles,
          color: const Color(0xFF944EF8),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (context, index) =>
            const SizedBox(height: 16),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              return VehicleCardModern(vehicle: vehicles[index]);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Addvehicle()),
          );
          _loadVehicles();
        },
        backgroundColor: const Color(0xFF944EF8),
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty_garage.png', // Make sure to add this image to your assets
            height: 180,
            color: Colors.grey[300],
            colorBlendMode: BlendMode.modulate,
          ),
          const SizedBox(height: 24),
          Text(
            "Your garage is empty",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Add your first vehicle to get started",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Addvehicle()),
              );
              _loadVehicles();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF944EF8),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Add Vehicle",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VehicleCardModern extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleCardModern({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Vehicle Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.grey[200]!,
                        Colors.grey[100]!,
                      ],
                    ),
                  ),
                  child: vehicle.picUrl.isNotEmpty
                      ? Image.network(
                    vehicle.picUrl,
                    fit: BoxFit.cover,
                  )
                      : Center(
                    child: Image.asset(
                      'assets/images/car_placeholder.png', // Add this placeholder image
                      height: 80,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      vehicle.vehicleNo ?? 'N/A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Vehicle Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      vehicle.model ?? 'Unknown Model',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // if (vehicle.year != null)
                    //   Text(
                    //     '${vehicle.year}',
                    //     style: TextStyle(
                    //       fontSize: 14,
                    //       color: Colors.grey[600],
                    //     ),
                    //   ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.speed, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    // Text(
                    //   vehicle.mileage != null
                    //       ? '${vehicle.mileage} km'
                    //       : 'Mileage not set',
                    //   style: TextStyle(
                    //     fontSize: 14,
                    //     color: Colors.grey[600],
                    //   ),
                    // ),
                    const SizedBox(width: 16),
                    Icon(Icons.date_range, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    // Text(
                    //   vehicle.lastService != null
                    //       ? 'Last service: ${vehicle.lastService}'
                    //       : 'No service history',
                    //   style: TextStyle(
                    //     fontSize: 14,
                    //     color: Colors.grey[600],
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // View details action
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VehicleDetailsPage(vehicleNo: vehicle.vehicleNo),
                            ),
                          );
                        },
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: const Text('Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF944EF8),
                          side: const BorderSide(color: Color(0xFF944EF8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Service now action
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Bookappointment()));
                        },
                        icon: const Icon(Icons.build, size: 18),
                        label: const Text('Service'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFd9baf4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}