import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // Base URLs for localhost / Android Emulator / Production Render Deployment
  // For production deployment on Render, replace with:
  // static const String renderProductionUrl = 'https://fuzzylogic-student-predictor-api.onrender.com/api';

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000/api';
    return 'http://127.0.0.1:5000/api';
  }

  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
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
        return 'Server connection timed out. Please check backend server.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Cannot connect to backend server at $baseUrl. Ensure Node.js backend is running.';
      }
      if (error.response?.data != null && error.response?.data['message'] != null) {
        return error.response!.data['message'].toString();
      }
    }
    return error.toString();
  }
}
