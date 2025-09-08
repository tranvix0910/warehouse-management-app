import 'package:dio/dio.dart';
import '../utils/token_storage.dart';
import '../config/api_constants.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {"Content-Type": "application/json"},
    ),
  );

  static void init() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getAccessToken();
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            final refreshed = await _refreshAccessToken();

            if (refreshed) {
              final newToken = await TokenStorage.getAccessToken();
              e.requestOptions.headers["Authorization"] = "Bearer $newToken";
              final cloneReq = await dio.fetch(e.requestOptions);
              return handler.resolve(cloneReq);
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  static Future<bool> _refreshAccessToken() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await dio.post(
        "/auth/refreshToken",
        data: {"refreshToken": refreshToken},
        options: Options(headers: {"Authorization": null}), // tránh loop
      );

      if (response.statusCode == 200 &&
          response.data["accessToken"] != null &&
          response.data["refreshToken"] != null) {
        final newAccessToken = response.data["accessToken"];
        final newRefreshToken = response.data["refreshToken"];
        await TokenStorage.saveTokens(newAccessToken, newRefreshToken);
        return true;
      }
    } catch (e) {
      print("❌ Refresh token failed: $e");
    }
    return false;
  }
}
