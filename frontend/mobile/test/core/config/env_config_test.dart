import 'package:flutter_test/flutter_test.dart';
import 'package:zimbite/core/config/env_config.dart';
import 'package:zimbite/core/maps/map_provider_type.dart';

void main() {
  test('loadOptional does not throw when env loader fails', () async {
    final loaded = await EnvConfig.loadOptional(
      '.env.missing',
      loader: (_) async {
        throw Exception('missing file');
      },
    );

    expect(loaded, isFalse);
  });

  test('resolveApiBaseUrl falls back to default when missing', () {
    expect(EnvConfig.resolveApiBaseUrl({}), EnvConfig.defaultApiBaseUrl);
    expect(
      EnvConfig.resolveApiBaseUrl({'API_BASE_URL': '   '}),
      EnvConfig.defaultApiBaseUrl,
    );
    expect(
      EnvConfig.resolveApiBaseUrl({
        'API_BASE_URL': 'https://api.zimbite.co.zw',
      }),
      'https://api.zimbite.co.zw',
    );
  });

  test('resolveGoogleMapsApiKey falls back to empty string', () {
    expect(EnvConfig.resolveGoogleMapsApiKey({}), '');
    expect(
      EnvConfig.resolveGoogleMapsApiKey({'GOOGLE_MAPS_API_KEY': 'demo-key'}),
      'demo-key',
    );
  });

  test('resolveMapProvider defaults by build mode when not configured', () {
    expect(
      EnvConfig.resolveMapProvider({}, isReleaseMode: false),
      MapProviderType.osm,
    );
    expect(
      EnvConfig.resolveMapProvider({}, isReleaseMode: true),
      MapProviderType.google,
    );
  });

  test('resolveMapProvider uses explicit environment override', () {
    expect(
      EnvConfig.resolveMapProvider({
        'MAP_PROVIDER': 'google',
      }, isReleaseMode: false),
      MapProviderType.google,
    );
    expect(
      EnvConfig.resolveMapProvider({
        'MAP_PROVIDER': 'osm',
      }, isReleaseMode: true),
      MapProviderType.osm,
    );
  });
}
