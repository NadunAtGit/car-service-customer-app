import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sdp_app/utils/DioInstance.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceStatusCardList extends StatefulWidget {
  const ServiceStatusCardList({super.key});

  @override
  State<ServiceStatusCardList> createState() => _ServiceStatusCardListState();
}

class _ServiceStatusCardListState extends State<ServiceStatusCardList> {
  late Future<List<Map<String, dynamic>>> _futureJobCards;

  Future<List<Map<String, dynamic>>> fetchNotFinishedJobCards() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) {
        print("fetchNotFinishedJobCards: No authentication token found.");
        return [];
      }

      Response? response = await DioInstance.getRequest(
        '/api/customers/get-notfinished-jobcards',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response == null) {
        print("fetchNotFinishedJobCards: No response from server.");
        return [];
      }

      if (response.statusCode == 200 && response.data['success'] == true) {
        if (response.data['jobCards'] is List) {
          return List<Map<String, dynamic>>.from(response.data['jobCards']);
        } else {
          print("fetchNotFinishedJobCards: jobCards is not a List.");
          return [];
        }
      } else {
        print("fetchNotFinishedJobCards: Server error or unsuccessful response. "
            "Status: ${response.statusCode}, Data: ${response.data}");
        return [];
      }
    } on DioError catch (dioErr) {
      print("fetchNotFinishedJobCards: DioError - ${dioErr.message}");
      if (dioErr.response != null) {
        print("DioError response data: ${dioErr.response?.data}");
      }
      return [];
    } catch (e, stack) {
      print("fetchNotFinishedJobCards: Unexpected error - $e\n$stack");
      return [];
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'created':
        return Colors.grey;
      case 'assigned':
        return Colors.blue;
      case 'ongoing':
        return Colors.orange;
      case 'finished':
        return Colors.green;
      default:
        return Colors.black54;
    }
  }

  @override
  void initState() {
    super.initState();
    _futureJobCards = fetchNotFinishedJobCards();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureJobCards,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final jobCards = snapshot.data ?? [];
        if (jobCards.isEmpty) {
          return const Center(child: SizedBox(
            height: 10.0,
          ));
        }

        // Extract only the first job card, even if multiple are returned
        final card = jobCards[0];
        final status = card['Status'] ?? '';
        final jobCardId = card['JobCardID'] ?? '';
        final estCompletion = card['EstimatedCompletionTime'] ?? "N/A";

        // Return a single Container without specifying width
        return Container(
          // No width specified - will expand to parent width
          margin: EdgeInsets.only(bottom: 8.0, top: 8.0),
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
                    color: getStatusColor(status).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.build_outlined,
                    size: 32.0,
                    color: getStatusColor(status),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Job Card $jobCardId",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: getStatusColor(status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          if (estCompletion != "N/A")
                            Flexible(
                              child: Text(
                                "Est. completion: $estCompletion",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
      },
    );
  }


}
