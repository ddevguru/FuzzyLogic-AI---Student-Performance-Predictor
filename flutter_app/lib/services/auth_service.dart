import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _apiService.client.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.data['success'] == true) {
        final token = response.data['token'];
        await _saveToken(token);
        return UserModel.fromJson(response.data['user']);
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String rollNumber,
    required String course,
    required String department,
    required int semester,
  }) async {
    try {
      final response = await _apiService.client.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'rollNumber': rollNumber,
        'course': course,
        'department': department,
        'semester': semester,
      });

      if (response.data['success'] == true) {
        final token = response.data['token'];
        await _saveToken(token);
        return UserModel.fromJson(response.data['user']);
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  Future<UserModel?> getMe() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await _apiService.client.get('/auth/me');
      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['user']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
