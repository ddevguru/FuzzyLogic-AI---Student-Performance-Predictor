import 'package:flutter/material.dart';
import '../models/prediction_model.dart';
import '../services/api_service.dart';

class PredictionProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;
  
  PredictionRecord? _activePrediction;
  List<PredictionRecord> _history = [];
  Map<String, dynamic>? _dashboardData;
  String _selectedFilter = 'All';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PredictionRecord? get activePrediction => _activePrediction;
  List<PredictionRecord> get history => _history;
  Map<String, dynamic>? get dashboardData => _dashboardData;
  String get selectedFilter => _selectedFilter;

  Future<void> fetchDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.client.get('/dashboard');
      if (res.data['success'] == true) {
        _dashboardData = res.data['dashboard'];
      }
    } catch (e) {
      _errorMessage = _apiService.handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHistory([String filter = 'All']) async {
    _selectedFilter = filter;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.client.get('/predictions', queryParameters: {
        'level': filter,
      });

      if (res.data['success'] == true) {
        final list = res.data['predictions'] as List;
        _history = list.map((item) => PredictionRecord.fromJson(item)).toList();
      }
    } catch (e) {
      _errorMessage = _apiService.handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PredictionRecord?> createPrediction({
    required double attendance,
    required double testScore,
    required double assignmentScore,
    required double studyHours,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.client.post('/predictions', data: {
        'attendance': attendance,
        'testScore': testScore,
        'assignmentScore': assignmentScore,
        'studyHours': studyHours,
      });

      if (res.data['success'] == true) {
        final record = PredictionRecord.fromJson(res.data);
        _activePrediction = record;
        await fetchHistory(_selectedFilter);
        await fetchDashboard();
        return record;
      } else {
        throw Exception(res.data['message'] ?? 'Prediction analysis failed');
      }
    } catch (e) {
      _errorMessage = _apiService.handleError(e);
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setActivePrediction(PredictionRecord record) {
    _activePrediction = record;
    notifyListeners();
  }
}
