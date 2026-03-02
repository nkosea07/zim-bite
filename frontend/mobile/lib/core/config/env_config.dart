import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../maps/map_provider_type.dart';

class EnvConfig {
  static const String defaultApiBaseUrl = 'http://10.0.2.2:8080';

  static String get apiBaseUrl => resolveApiBaseUrl(dotenv.env);

  static String get wsBaseUrl =>
      dotenv.env['WS_BASE_URL'] ?? 'ws://localhost:8088/ws';

  static String get googleMapsApiKey => resolveGoogleMapsApiKey(dotenv.env);

  static MapProviderType get mapProvider =>
      resolveMapProvider(dotenv.env, isReleaseMode: kReleaseMode);

  static String resolveApiBaseUrl(Map<String, String> env) {
    final raw = env['API_BASE_URL']?.trim();
    if (raw == null || raw.isEmpty) {
      return defaultApiBaseUrl;
    }
    return raw;
  }

  static String resolveGoogleMapsApiKey(Map<String, String> env) {
    return env['GOOGLE_MAPS_API_KEY']?.trim() ?? '';
  }

  static MapProviderType resolveMapProvider(
    Map<String, String> env, {
    required bool isReleaseMode,
  }) {
    final raw = env['MAP_PROVIDER'];
    if (raw != null && raw.trim().isNotEmpty) {
      return MapProviderType.fromRaw(raw);
    }
    return isReleaseMode ? MapProviderType.google : MapProviderType.osm;
  }

  static Future<bool> loadOptional(
    String fileName, {
    Future<void> Function(String fileName)? loader,
  }) async {
    final envLoader = loader ?? ((name) => dotenv.load(fileName: name));
    try {
      await envLoader(fileName);
      return true;
    } catch (error) {
      debugPrint('Env file "$fileName" was not loaded: $error');
      return false;
    }
  }
}
