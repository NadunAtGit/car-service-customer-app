import 'package:sdp_app/utils/DioInstance.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PendingInvoice {
  final String invoiceId;
  final double total;
  final double partsCost;
  final double labourCost;
  final DateTime generatedDate;
  final String paidStatus;
  final String jobCardId;
  final String appointmentId;
  final String vehicleNo;
  final String model;

  PendingInvoice({
    required this.invoiceId,
    required this.total,
    required this.partsCost,
    required this.labourCost,
    required this.generatedDate,
    required this.paidStatus,
    required this.jobCardId,
    required this.appointmentId,
    required this.vehicleNo,
    required this.model,
  });

  factory PendingInvoice.fromJson(Map<String, dynamic> json) {
    return PendingInvoice(
      invoiceId: json['Invoice_ID'],
      total: double.parse(json['Total']),
      partsCost: double.parse(json['Parts_Cost']),
      labourCost: double.parse(json['Labour_Cost']),
      generatedDate: DateTime.parse(json['GeneratedDate']),
      paidStatus: json['PaidStatus'],
      jobCardId: json['JobCardID'],
      appointmentId: json['AppointmentID'],
      vehicleNo: json['VehicleNo'],
      model: json['Model'],
    );
  }
}

class InvoiceService {
  static Future<List<PendingInvoice>> fetchPendingInvoices() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        print("Token is missing.");
        return [];
      }

      Response? response = await DioInstance.getRequest(
        '/api/customers/pending-invoices',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response != null && response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;

        if (responseData['success'] == true) {
          final List<dynamic> invoicesData = responseData['data'];
          return invoicesData.map((json) => PendingInvoice.fromJson(json)).toList();
        } else {
          print('Failed response: ${responseData}');
        }
      } else {
        print("Response error or null: ${response?.statusCode}");
      }
      return [];
    } catch (e) {
      print('Error fetching pending invoices: $e');
      return [];
    }
  }
}
