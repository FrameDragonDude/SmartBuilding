import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'interceptor.dart';

class ApiClient {
  late final Dio dio;

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5169/api';
    } else {
      return 'http://10.0.2.2:5169/api';
    }
  }

  ApiClient() {
    dio = Dio(
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

    dio.interceptors.addAll([AuthorizationInterceptor(), LoggerInterceptor()]);
  }
}
