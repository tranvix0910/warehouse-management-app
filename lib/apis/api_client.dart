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
  
  static bool _isRefreshing = false;

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
            // Nếu đang refresh, từ chối request này
            if (_isRefreshing) {
              return handler.next(e);
            }

            _isRefreshing = true;
            
            try {
              final refreshed = await _refreshAccessToken();
              
              if (refreshed) {
                final newToken = await TokenStorage.getAccessToken();
                
                // Retry original request với token mới
                e.requestOptions.headers["Authorization"] = "Bearer $newToken";
                final cloneReq = await dio.fetch(e.requestOptions);
                return handler.resolve(cloneReq);
              } else {
                // Refresh thất bại, clear tokens
                await TokenStorage.clearTokens();
                await TokenStorage.clearUser();
              }
            } catch (refreshError) {
              await TokenStorage.clearTokens();
              await TokenStorage.clearUser();
            } finally {
              _isRefreshing = false;
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
      // Tạo một Dio instance riêng cho refresh token để tránh loop
      final refreshDio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: {"Content-Type": "application/json"},
      ));

      final response = await refreshDio.post(
        "/auth/refreshToken",
        data: {"refreshToken": refreshToken},
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
      // Nếu refresh token thất bại, xóa tokens để buộc user login lại
      await TokenStorage.clearTokens();
      await TokenStorage.clearUser();
    }
    return false;
  }
}
