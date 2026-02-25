import 'package:dio/dio.dart';

import '../config/app_constants.dart';

class DioClient {
  final Dio dio;

  DioClient({required String baseUrl})
      : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: AppConstants.httpTimeout,
            receiveTimeout: AppConstants.httpTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

  /// Appends an interceptor to the Dio interceptor chain.
  void addInterceptor(Interceptor interceptor) {
    dio.interceptors.add(interceptor);
  }
}
