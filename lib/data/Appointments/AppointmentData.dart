import 'package:sdp_app/utils/DioInstance.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Appointment {
  final String id;
  final DateTime dateTime;
  final String vehicleModel;
  final String vehicleNumber;
  final bool isConfirmed;
  final String? notes;

  Appointment({
    required this.id,
    required this.dateTime,
    required this.vehicleModel,
    required this.vehicleNumber,
    required this.isConfirmed,
    this.notes,
  });

  // Factory method to create an Appointment object from JSON
  factory Appointment.fromJson(Map<String, dynamic> json) {
    // Debug: Print raw JSON data
    print("Parsing appointment JSON: ${json.toString().substring(0, json.toString().length > 100 ? 100 : json.toString().length)}...");

    // Parse the date string to DateTime
    DateTime appointmentDateTime;
    try {
      if (json["Date"] != null) {
        // First try to parse the Date field
        String dateStr = json["Date"];
        if (json["Time"] != null) {
          // If there's a separate Time field, combine them
          String timeStr = json["Time"];
          // Remove the 'T' and everything after if it exists
          dateStr = dateStr.split('T')[0];
          appointmentDateTime = DateTime.parse("${dateStr}T${timeStr}");
        } else {
          // Otherwise just parse the Date field
          appointmentDateTime = DateTime.parse(dateStr);
        }
        print("Successfully parsed date: ${json["Date"]} to $appointmentDateTime");
      } else if (json["AppointmentDate"] != null) {
        // Try the AppointmentDate field as a fallback
        appointmentDateTime = DateTime.parse(json["AppointmentDate"]);
        print("Successfully parsed date: ${json["AppointmentDate"]} to $appointmentDateTime");
      } else {
        print("Warning: No date field found, using current time");
        appointmentDateTime = DateTime.now();
      }
    } catch (e) {
      print("Error parsing date: $e");
      appointmentDateTime = DateTime.now();
    }

    // Handle vehicle number field which might be VehicleID or VehicleNo
    String vehicleNumber = '';
    if (json["VehicleID"] != null) {
      vehicleNumber = json["VehicleID"].toString();
    } else if (json["VehicleNo"] != null) {
      vehicleNumber = json["VehicleNo"].toString();
    }

    // Debug: Print extracted values
    print("Creating Appointment with ID: ${json["AppointmentID"] ?? 'null'}, " +
        "Vehicle: ${json["VehicleModel"] ?? 'null'} ($vehicleNumber), " +
        "Status: ${json["Status"] ?? 'null'}, " +
        "isConfirmed: ${json["Status"] == 'Confirmed'}");

    return Appointment(
      id: json["AppointmentID"]?.toString() ?? '',
      dateTime: appointmentDateTime,
      vehicleModel: json["VehicleModel"]?.toString() ?? '',
      vehicleNumber: vehicleNumber,
      isConfirmed: json["Status"] == 'Confirmed',
      notes: json["Notes"]?.toString(),
    );
  }

  // Helper method to format date
  String getFormattedDate() {
    return DateFormat('EEE, MMM d, yyyy').format(dateTime);
  }

  // Helper method to format time
  String getFormattedTime() {
    return DateFormat('h:mm a').format(dateTime);
  }

  // Helper method to check if appointment is upcoming
  bool isUpcoming() {
    final now = DateTime.now();
    return dateTime.isAfter(now);
  }

  // Helper method to check if appointment is today
  bool isToday() {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  @override
  String toString() {
    return 'Appointment{id: $id, dateTime: $dateTime, vehicleModel: $vehicleModel, vehicleNumber: $vehicleNumber, isConfirmed: $isConfirmed}';
  }
}

// Function to fetch not confirmed appointments from API
Future<List<Appointment>> fetchNotConfirmedAppointments() async {
  print("Fetching not confirmed appointments...");
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print("Error: Token is missing.");
      return []; // Return empty list if no token
    }

    print("Making API request to /api/customers/get-notconfirmed-appointments");
    Response? response = await DioInstance.getRequest(
      "/api/customers/get-notconfirmed-appointments",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    if (response != null && response.statusCode == 200 && response.data["success"] == true) {
      print("Successfully fetched not confirmed appointment data");
      List<dynamic> appointmentList = response.data["appointments"];
      print("Received ${appointmentList.length} not confirmed appointments");

      List<Appointment> appointments = appointmentList
          .map((appointment) => Appointment.fromJson(appointment))
          .toList();

      print("Parsed ${appointments.length} not confirmed appointments");
      return appointments;
    } else {
      print("Failed to fetch not confirmed appointment data: ${response?.statusCode} - ${response?.data}");
      return [];
    }
  } catch (e) {
    print("Exception while fetching not confirmed appointment data: $e");
    return [];
  }
}

// Function to fetch confirmed appointments from API
Future<List<Appointment>> fetchConfirmedAppointments() async {
  print("Fetching confirmed appointments...");
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print("Error: Token is missing.");
      return []; // Return empty list if no token
    }

    print("Making API request to /api/appointments/get-confirmed-user");
    Response? response = await DioInstance.getRequest(
      "/api/appointments/get-confirmed-user",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    if (response != null && response.statusCode == 200 && response.data["success"] == true) {
      print("Successfully fetched confirmed appointment data");
      List<dynamic> appointmentList = response.data["appointments"];
      print("Received ${appointmentList.length} confirmed appointments");

      List<Appointment> appointments = appointmentList
          .map((appointment) => Appointment.fromJson(appointment))
          .toList();

      print("Parsed ${appointments.length} confirmed appointments");

      // Sort appointments by date (earliest first)
      appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      return appointments;
    } else {
      print("Failed to fetch confirmed appointment data: ${response?.statusCode} - ${response?.data}");
      return [];
    }
  } catch (e) {
    print("Exception while fetching confirmed appointment data: $e");
    return [];
  }
}

// Function to get not confirmed appointments
Future<List<Appointment>> getNotConfirmedAppointments() async {
  print("Getting not confirmed appointments...");
  return await fetchNotConfirmedAppointments();
}

// Function to get confirmed appointments
Future<List<Appointment>> getConfirmedAppointments() async {
  print("Getting confirmed appointments...");
  return await fetchConfirmedAppointments();
}

// Function to get the closest confirmed appointment
Future<Appointment?> getClosestConfirmedAppointment() async {
  print("Getting closest confirmed appointment...");
  try {
    final confirmedAppointments = await fetchConfirmedAppointments();

    if (confirmedAppointments.isEmpty) {
      print("No confirmed appointments found");
      return null;
    }

    // For demonstration purposes, return the first appointment
    // In a real app, you would filter for upcoming appointments
    // final now = DateTime.now();
    // final upcomingAppointments = confirmedAppointments
    //     .where((apt) => apt.dateTime.isAfter(now))
    //     .toList();

    // if (upcomingAppointments.isEmpty) {
    //   print("No upcoming confirmed appointments found");
    //   return null;
    // }

    // Since we already sorted in fetchConfirmedAppointments, just return the first one
    print("Found closest confirmed appointment: ${confirmedAppointments[0]}");
    return confirmedAppointments[0];
  } catch (e) {
    print("Error getting closest confirmed appointment: $e");
    return null;
  }
}

// Function to get all appointments
Future<List<Appointment>> getAllAppointments() async {
  print("Getting all appointments...");
  try {
    final notConfirmed = await fetchNotConfirmedAppointments();
    final confirmed = await fetchConfirmedAppointments();

    final allAppointments = [...confirmed, ...notConfirmed];
    print("Total appointments: ${allAppointments.length} (${confirmed.length} confirmed, ${notConfirmed.length} not confirmed)");

    // Sort by date (earliest first)
    allAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return allAppointments;
  } catch (e) {
    print("Error getting all appointments: $e");
    return [];
  }
}
