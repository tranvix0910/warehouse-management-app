import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/token_storage.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? userId;
  final String? username;
  final String? email;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.userId,
    this.username,
    this.email,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? userId,
    String? username,
    String? email,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final token = await TokenStorage.getAccessToken();
      final user = await TokenStorage.getUser();
      
      if (token != null && user != null) {
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          userId: user['id'],
          username: user['username'],
          email: user['email'],
        );
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> login({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> user,
  }) async {
    await TokenStorage.saveTokens(accessToken, refreshToken);
    await TokenStorage.saveUser(user);
    
    state = state.copyWith(
      isAuthenticated: true,
      userId: user['id'],
      username: user['username'],
      email: user['email'],
    );
  }

  Future<void> logout() async {
    await TokenStorage.clearTokens();
    await TokenStorage.clearUser();
    
    state = const AuthState();
  }

  Future<void> updateUser(Map<String, dynamic> user) async {
    await TokenStorage.saveUser(user);
    
    state = state.copyWith(
      userId: user['id'],
      username: user['username'],
      email: user['email'],
    );
  }
}
