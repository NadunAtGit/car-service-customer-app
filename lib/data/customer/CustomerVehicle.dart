import 'package:sdp_app/utils/DioInstance.dart';
import 'package:dio/dio.dart';

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

}

List<Vehicle> getVehicle(){
  return<Vehicle>[
    Vehicle(vehicleNo: "CAA-1876", model: "Nissan GTR", type: "Coupe", customerId:"C-0001", picUrl:"images/gtr.jpg"),
    Vehicle(vehicleNo: "CAA-1076", model: "Subaru Wrx", type: "Sedan", customerId:"C-0002", picUrl:"images/wrx.jpg"),
    Vehicle(vehicleNo: "CAA-1876", model: "Nissan GTR", type: "Coupe", customerId:"C-0001", picUrl:"images/gtr.jpg"),
  ];
}