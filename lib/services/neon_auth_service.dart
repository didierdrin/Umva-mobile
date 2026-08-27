// lib/services/neon_auth_service.dart
//
// Dart mirror of umva-dashboard/src/lib/authClient.js, talking to the same
// Neon Auth (Better Auth) REST API. The web dashboard relies on the browser's
// cookie jar (credentials: 'include'); Dart's http client has none, so this
// service captures the Set-Cookie header from sign-in/sign-up itself,
// persists it in secure storage, and replays it as a Cookie header on every
// later call - including on cold start, to restore a session via get-session.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'neon_config.dart';

class NeonAuthException implements Exception {
  final String message;
  NeonAuthException(this.message);
  @override
  String toString() => message;
}

class NeonAuthService {
  static const _cookieStorageKey = 'neon_auth_cookie';

  final http.Client _client;
  final FlutterSecureStorage _storage;

  // In-memory only: short-lived (~1h) and cheap to refetch, so there's no
  // need to persist it like the session cookie.
  String? _anonymousToken;
  DateTime? _anonymousTokenExpiry;

  NeonAuthService({http.Client? client, FlutterSecureStorage? storage})
      : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  Future<String?> _readCookie() => _storage.read(key: _cookieStorageKey);

  Future<void> _saveCookieFromResponse(http.Response res) async {
    final setCookie = res.headers['set-cookie'];
    if (setCookie == null) return;
    // A Set-Cookie header may bundle multiple cookies separated by commas in
    // some server implementations, but Better Auth sends one session cookie;
    // strip the attributes (Path=, HttpOnly, etc.) and keep the name=value pair.
    final cookiePair = setCookie.split(';').first.trim();
    await _storage.write(key: _cookieStorageKey, value: cookiePair);
  }

  Future<void> _clearCookie() => _storage.delete(key: _cookieStorageKey);

  Future<Map<String, dynamic>?> _call(
    String path, {
    String method = 'POST',
    Map<String, dynamic>? body,
  }) async {
    final cookie = await _readCookie();
    final headers = {
      'Content-Type': 'application/json',
      if (cookie != null) 'Cookie': cookie,
    };

    http.Response res;
    try {
      final uri = Uri.parse('${NeonConfig.authUrl}$path');
      res = method == 'GET'
          ? await _client.get(uri, headers: headers)
          : await _client.post(uri, headers: headers, body: body == null ? null : jsonEncode(body));
    } catch (_) {
      throw NeonAuthException('Cannot reach the authentication server. Check your connection.');
    }

    await _saveCookieFromResponse(res);

    final text = res.body;
    final data = text.isNotEmpty ? _safeParse(text) : null;

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final message = (data is Map && data['message'] is String) ? data['message'] as String : 'Request failed (${res.statusCode})';
      throw NeonAuthException(message);
    }
    return data is Map<String, dynamic> ? data : null;
  }

  dynamic _safeParse(String text) {
    try {
      return jsonDecode(text);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> signUp({required String name, required String email, required String password}) {
    return _call('/sign-up/email', body: {'name': name, 'email': email, 'password': password});
  }

  Future<Map<String, dynamic>?> signIn({required String email, required String password}) {
    return _call('/sign-in/email', body: {'email': email, 'password': password});
  }

  Future<void> signOut() async {
    try {
      await _call('/sign-out', body: const {});
    } finally {
      await _clearCookie();
    }
  }

  /// Null when signed out - the normal case, not an error worth surfacing.
  Future<Map<String, dynamic>?> getSession() async {
    try {
      return await _call('/get-session', method: 'GET');
    } catch (_) {
      return null;
    }
  }

  /// JWT for the Data API, scoped to the signed-in user. Null when signed
  /// out - callers fall back to [getAnonymousToken].
  Future<String?> getToken() async {
    try {
      final data = await _call('/token', method: 'GET');
      return data?['token'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// JWT for the Data API's `anonymous` role - no sign-in required. The
  /// Data API rejects requests with no Authorization header at all (it does
  /// not treat "no token" as "anonymous role" the way plain PostgREST
  /// would), so this is required for public browsing/search. Cached
  /// in-memory until shortly before it expires.
  Future<String?> getAnonymousToken() async {
    final cached = _anonymousToken;
    final expiry = _anonymousTokenExpiry;
    if (cached != null && expiry != null && DateTime.now().isBefore(expiry.subtract(const Duration(seconds: 30)))) {
      return cached;
    }
    try {
      final data = await _call('/token/anonymous', method: 'GET');
      final token = data?['token'] as String?;
      if (token == null) return null;
      final expiresAt = data?['expires_at'];
      _anonymousToken = token;
      _anonymousTokenExpiry = expiresAt is int
          ? DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000, isUtc: true)
          : DateTime.now().add(const Duration(minutes: 30));
      return token;
    } catch (_) {
      return null;
    }
  }
}
