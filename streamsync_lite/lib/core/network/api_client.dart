import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;
  String? _accessToken;

  ApiClient(this._dio);

  void setToken(String token) {
    _accessToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    _accessToken = null;
    _dio.options.headers.remove('Authorization');
  }

  // Auth
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }

  // Videos
  Future<List<dynamic>> getLatestVideos() async {
    final response = await _dio.get('/videos/latest');
    return response.data['data'] as List;
  }

  Future<void> saveProgress(String videoId, int positionSeconds, int completedPercent) async {
    await _dio.post('/videos/progress', data: {
      'videoId': videoId,
      'positionSeconds': positionSeconds,
      'completedPercent': completedPercent,
    });
  }

  Future<void> addFavorite(String videoId) async {
    await _dio.post('/videos/favorites', data: {'videoId': videoId});
  }

  Future<void> removeFavorite(String videoId) async {
    await _dio.delete('/videos/favorites/$videoId');
  }

  Future<List<dynamic>> getFavorites() async {
    final response = await _dio.get('/videos/favorites/user');
    return response.data['data'] as List;
  }

  // Notifications
  Future<void> registerFcmToken(String token, String platform) async {
    await _dio.post('/notifications/tokens', data: {
      'token': token,
      'platform': platform,
    });
  }

  Future<List<dynamic>> getNotifications() async {
    final response = await _dio.get('/notifications');
    return response.data['data'] as List;
  }

  Future<void> sendTestPush(String title, String body) async {
    await _dio.post('/notifications/send-test', data: {
      'title': title,
      'body': body,
    });
  }
}
