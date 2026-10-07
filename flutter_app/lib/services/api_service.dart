import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // Live Production Render Backend API URL
  static const String liveProductionUrl = 'https://fuzzylogic-student-predictor-api.onrender.com/api';
  static const String localFallbackUrl = 'http://127.0.0.1:5000/api';

  static String get baseUrl {
    return liveProductionUrl;
  }

  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 45),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          debugPrint('API Error [${e.response?.statusCode}]: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  Dio get client => _dio;

  // Helper method for human-readable error messages
  String handleError(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Server is waking up (Render cold start). Please wait 10 seconds and tap Login again.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Connecting to live server. Render free tier takes ~30s to spin up. Please try again in a moment.';
      }
      if (error.response?.data != null && error.response?.data['message'] != null) {
        return error.response!.data['message'].toString();
      }
    }
    return error.toString();
  }
}
