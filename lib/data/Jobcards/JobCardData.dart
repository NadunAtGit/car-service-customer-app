class JobCardResponse {
  final bool success;
  final List<JobCard> jobCards;
  final int count;

  JobCardResponse({
    required this.success,
    required this.jobCards,
    required this.count,
  });

  factory JobCardResponse.fromJson(Map<String, dynamic> json) {
    return JobCardResponse(
      success: json['success'] ?? false,
      jobCards: (json['jobCards'] as List?)
          ?.map((e) => JobCard.fromJson(e))
          .toList() ?? [],
      count: json['count'] ?? 0,
    );
  }
}

class JobCard {
  final String jobCardId;
  final String serviceDetails;
  final String type;
  final String? invoiceId;
  final String appointmentId;
  final String status;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String vehicleModel;
  final String vehicleType;
  final String vehicleNo;
  final List<ServiceRecord> services;

  JobCard({
    required this.jobCardId,
    required this.serviceDetails,
    required this.type,
    this.invoiceId,
    required this.appointmentId,
    required this.status,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.vehicleModel,
    required this.vehicleType,
    required this.vehicleNo,
    required this.services,
  });

  factory JobCard.fromJson(Map<String, dynamic> json) {
    return JobCard(
      jobCardId: json['JobCardID'] ?? '',
      serviceDetails: json['ServiceDetails'] ?? '',
      type: json['Type'] ?? '',
      invoiceId: json['InvoiceID'],
      appointmentId: json['AppointmentID'] ?? '',
      status: json['Status'] ?? '',
      appointmentDate: json['AppointmentDate'] != null
          ? DateTime.parse(json['AppointmentDate'])
          : DateTime.now(),
      appointmentTime: json['AppointmentTime'] ?? '',
      vehicleModel: json['VehicleModel'] ?? '',
      vehicleType: json['VehicleType'] ?? '',
      vehicleNo: json['VehicleNo'] ?? '',
      services: (json['Services'] as List?)
          ?.map((e) => ServiceRecord.fromJson(e))
          .toList() ?? [],
    );
  }
}

class ServiceRecord {
  final String serviceRecordId;
  final String description;
  final String jobCardId;
  final String vehicleId;
  final String serviceType;
  final String status;

  ServiceRecord({
    required this.serviceRecordId,
    required this.description,
    required this.jobCardId,
    required this.vehicleId,
    required this.serviceType,
    required this.status,
  });

  factory ServiceRecord.fromJson(Map<String, dynamic> json) {
    return ServiceRecord(
      serviceRecordId: json['ServiceRecord_ID'] ?? '',
      description: json['Description'] ?? '',
      jobCardId: json['JobCardID'] ?? '',
      vehicleId: json['VehicleID'] ?? '',
      serviceType: json['ServiceType'] ?? '',
      status: json['Status'] ?? '',
    );
  }
}
