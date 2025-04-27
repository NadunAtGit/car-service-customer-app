import 'package:dio/dio.dart';

class DioInstance {
  static final Dio dio = Dio(BaseOptions(
    baseUrl: "http://10.0.2.2:8000",
    connectTimeout: Duration(seconds: 8),
    receiveTimeout: Duration(seconds: 8),
    headers: {
      "Content-Type": "application/json",
    },
  ));

  // POST request
  static Future<Response?> postRequest(String path,
      Map<String, dynamic> data, {Options? options}) async {
    try {
      Response response = await dio.post(path, data: data, options: options);
      return response;
    } catch (e) {
      print("Dio Error: $e");
      return null;
    }
  }

  // GET request (modified to accept options)
  static Future<Response?> getRequest(String path, {Options? options}) async {
    try {
      Response response = await dio.get(
          path, options: options); // Pass the options
      return response;
    } catch (e) {
      print("Dio Error: $e");
      return null;
    }
  }

  // PUT request
// Add 'options' parameter to putRequest method
  static Future<Response?> putRequest(String path, Map<String, dynamic> data,
      {Options? options}) async {
    try {
      Response response = await dio.put(path, data: data, options: options);
      return response;
    } catch (e) {
      print("Dio Error: $e");
      return null;
    }
  }

  // DELETE request
  static Future<Response?> deleteRequest(String path,
      {Options? options}) async {
    try {
      Response response = await dio.delete(
          path,
          options: options
      );
      return response;
    } catch (e) {
      print("Dio Error: $e");
      return null;
    }
  }

}


