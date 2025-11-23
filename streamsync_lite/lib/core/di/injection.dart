import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() {
  // Register Dio
  getIt.registerSingleton<Dio>(_createDio());
}

Dio _createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:3000/api',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  return dio;
}
