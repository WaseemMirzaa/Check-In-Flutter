
import 'dart:convert';
import 'package:dio/dio.dart';

class DioHelper {
  static String baseURL = "https://us-central1-check-in-7ecd7.cloudfunctions.net/";
  static String apiErrorResponse = "Something went wrong! Please try again";

  static const ERROR = "error";
  static const SUCCESS = "success";

  static String getJsonString(Map<String,dynamic> map){
    Map<String, dynamic> castedMap = {};
    map.forEach((key, value) {
      castedMap[key.toString()] = value;
    });

    return jsonEncode(castedMap);
  }

  static Future<ApiResponse> postRawData(String url, String jsonString) async {
    var dio = Dio();
    try {
      final response = await dio.post(url,
        data: jsonString,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),);

      if (response.data != null && response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 202 ||
          response.statusCode == 203 ||
          response.statusCode == 204 ||
          response.statusCode == 205) {
        var jsonString = json.encode(response.data);
        return ApiResponse(jsonString, true);
      } else{
        return ApiResponse(null, false);
      }
    } on DioException catch (e) {
      return ApiResponse(null, false);
    }
  }

}

class ApiResponse {
  dynamic body;
  bool isSuccess;

  ApiResponse(this.body, this.isSuccess);
}