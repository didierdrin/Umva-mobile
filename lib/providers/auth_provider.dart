import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import '../services/neon_auth_service.dart';

class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isSignedIn => user != null;

  AuthState copyWith({AppUser? user, bool clearUser = false, bool? isLoading, String? error, bool clearError = false}) =>
      AuthState(
        user: clearUser ? null : (user ?? this.user),
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final NeonAuthService _service;

  AuthNotifier(this._service) : super(const AuthState()) {
    restoreSession();
  }

  AppUser? _userFromSession(Map<String, dynamic>? session) {
    final userJson = session?['user'];
    if (userJson is! Map<String, dynamic>) return null;
    return AppUser.fromJson(userJson);
  }

  Future<void> restoreSession() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final session = await _service.getSession();
    final user = _userFromSession(session);
    state = AuthState(user: user, isLoading: false);
  }

  Future<bool> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _service.signIn(email: email, password: password);
      final user = _userFromSession(res) ?? AppUser(id: '', name: '', email: email);
      state = AuthState(user: user, isLoading: false);
      // sign-in/email's response doesn't always echo the full user record;
      // get-session is the source of truth once the cookie is stored.
      await restoreSession();
      return true;
    } on NeonAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  Future<bool> signUp({required String name, required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _service.signUp(name: name, email: email, password: password);
      await restoreSession();
      return true;
    } on NeonAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _service.signOut();
    state = const AuthState();
  }
}

final neonAuthServiceProvider = Provider<NeonAuthService>((ref) => NeonAuthService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(neonAuthServiceProvider)),
);
