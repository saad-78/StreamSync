import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import '../../data/models/video_model.dart';

class ApiService {
  final Dio _dio;
  final SecureStorage _storage;

  // Update this to your backend URL
static const String baseUrl = 'http://127.0.0.1:3000/api';

  // For iOS simulator: 'http://localhost:3000/api'
  // For real device: 'http://YOUR_IP:3000/api'

  ApiService(this._dio, this._storage) {
    _dio.options.baseUrl = baseUrl;
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired, try refresh
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry original request
            final opts = error.requestOptions;
            final token = await _storage.getAccessToken();
            opts.headers['Authorization'] = 'Bearer $token';
            final response = await _dio.fetch(opts);
            return handler.resolve(response);
          }
        }
        return handler.next(error);
      },
    ));
  }

  // Auth
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
    
    if (response.data['success']) {
      final data = response.data['data'];
      await _storage.saveTokens(data['accessToken'], data['refreshToken']);
      return data['user'];
    }
    throw Exception(response.data['error'] ?? 'Registration failed');
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    
    if (response.data['success']) {
      final data = response.data['data'];
      await _storage.saveTokens(data['accessToken'], data['refreshToken']);
      return data['user'];
    }
    throw Exception(response.data['error'] ?? 'Login failed');
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (response.data['success']) {
        final newToken = response.data['data']['accessToken'];
        await _storage.saveAccessToken(newToken);
        return true;
      }
    } catch (_) {}
    return false;
  }

  // Videos
  Future<List<VideoModel>> getLatestVideos() async {
    final response = await _dio.get('/videos/latest');
    if (response.data['success']) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => VideoModel.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch videos');
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
    return response.data['data'];
  }

  Future<List<dynamic>> getUserProgress() async {
    final response = await _dio.get('/videos/progress/user');
    return response.data['data'];
  }

  // Notifications
  Future<void> registerFcmToken(String token, String platform) async {
    await _dio.post('/notifications/tokens', data: {
      'token': token,
      'platform': platform,
    });
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await _dio.get('/notifications');
    if (response.data['success']) {
      return List<Map<String, dynamic>>.from(response.data['data']);
    }
    return [];
  }

  Future<void> markAsRead(String notificationId) async {
    await _dio.post('/notifications/mark-read', data: {
      'notificationId': notificationId,
    });
  }

  Future<void> deleteNotification(String notificationId) async {
    await _dio.delete('/notifications/$notificationId');
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get('/notifications/unread-count');
    return response.data['data']['count'] ?? 0;
  }

  Future<void> sendTestPush(String title, String body) async {
    await _dio.post('/notifications/send-test', data: {
      'title': title,
      'body': body,
    });
  }
}
