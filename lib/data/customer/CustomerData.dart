import 'package:dio/dio.dart';
import 'package:sdp_app/utils/DioInstance.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Customer {
  final String customerID;
  final String firstName;
  final String secondName;
  final String telephone;
  final String email;
  final String username;
  final String profilePicUrl;

  Customer({
    required this.customerID,
    required this.firstName,
    required this.secondName,
    required this.telephone,
    required this.email,
    required this.username,
    required this.profilePicUrl,
  });

  // Factory constructor to create an object from JSON
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerID: json['CustomerID'],
      firstName: json['FirstName'],
      secondName: json['SecondName'],
      telephone: json['Telephone'],
      email: json['Email'],
      username: json['Username'],
      profilePicUrl: json['profilePicUrl'] ?? "", // Default empty string if null
    );
  }
}

Future<Customer?> fetchCustomerData() async {
  try {
    // Get token from SharedPreferences or another secure location
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); // Replace 'authToken' with the correct key

    if (token == null) {
      print("Token is missing.");
      return null; // or handle token missing case
    }

    // Set token in the request headers
    Response? response = await DioInstance.getRequest(
      "/api/customers/get-info",
      options: Options(
        headers: {
          "Authorization": "Bearer $token", // Add the token in the Authorization header
        },
      ),
    );

    if (response != null && response.statusCode == 200 && response.data["success"] == true) {
      return Customer.fromJson(response.data["customerInfo"]);
    } else {
      print("Failed to fetch customer data: ${response?.data}");
      return null;
    }
  } catch (e) {
    print("Error fetching customer info: $e");
    return null;
  }
}
