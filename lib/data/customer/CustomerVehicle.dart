import 'package:sdp_app/utils/DioInstance.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Vehicle {
  final String vehicleNo;
  final String model;
  final String type;
  final String customerId;
  final String picUrl;

  // Constructor
  Vehicle({
    required this.vehicleNo,
    required this.model,
    required this.type,
    required this.customerId,
    required this.picUrl,
  });

  // Factory method to create a Vehicle object from JSON
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vehicleNo: json["VehicleNo"],
      model: json["Model"],
      type: json["Type"],
      customerId: json["CustomerID"],
      picUrl: json["VehiclePicUrl"] ?? "images/default.jpg", // Provide a default image
    );
  }
}

// Function to fetch customer vehicles from API
Future<List<Vehicle>> fetchCustomerVehicles() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print("Token is missing.");
      return []; // Return empty list if no token
    }

    Response? response = await DioInstance.getRequest(
      "/api/customers/get-vehicles",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    if (response != null && response.statusCode == 200 && response.data["success"] == true) {
      print("Fetched data successfully");
      List<dynamic> vehicleList = response.data["vehicleInfo"];
      return vehicleList.map((vehicle) => Vehicle.fromJson(vehicle)).toList();
    } else {
      print("Failed to fetch vehicle data: ${response?.data}");
      return [];
    }
  } catch (e) {
    print("Error fetching vehicle data: $e");
    return [];
  }
}

// Function to get vehicle list dynamically
Future<List<Vehicle>> getVehicle() async {
  return await fetchCustomerVehicles();
}
