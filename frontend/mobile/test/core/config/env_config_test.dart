import 'package:flutter_test/flutter_test.dart';
import 'package:zimbite/core/config/env_config.dart';

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
      EnvConfig.resolveApiBaseUrl({'API_BASE_URL': 'https://api.zimbite.co.zw'}),
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
}
