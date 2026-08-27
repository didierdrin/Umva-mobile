// lib/services/neon_config.dart
//
// Base URLs for the same Neon Data API / Neon Auth backend the dashboard
// (umva-dashboard) talks to via REACT_APP_NEON_DATA_API_URL /
// REACT_APP_NEON_AUTH_URL. The mobile app has no build-time env injection,
// so these are plain constants instead.

class NeonConfig {
  NeonConfig._();

  static const String authUrl =
      'https://ep-mute-math-b21g7jq4.neonauth.c-6.eu-central-1.aws.neon.tech/neondb/auth';

  static const String dataApiUrl =
      'https://ep-mute-math-b21g7jq4.apirest.c-6.eu-central-1.aws.neon.tech/neondb/rest/v1';
}
