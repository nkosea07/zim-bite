enum MapProviderType {
  osm,
  google;

  static MapProviderType fromRaw(String? raw) {
    final normalized = raw?.trim().toLowerCase();
    return switch (normalized) {
      'google' => MapProviderType.google,
      _ => MapProviderType.osm,
    };
  }

  String get label => this == MapProviderType.google ? 'Google Maps' : 'OSM';
}
