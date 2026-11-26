/// Metadata descriptor for a curated offline nature wallpaper bundled in assets.
class BuiltInWallpaper {
  const BuiltInWallpaper({
    required this.id,
    required this.assetPath,
    required this.nameEn,
    required this.nameAr,
  });

  final String id;
  final String assetPath;
  final String nameEn;
  final String nameAr;

  /// Canonical settings token stored in `customBackgroundImagePath`.
  String get sourceRef => 'asset:$assetPath';
}

/// Curated offline nature wallpapers (compressed local assets, zero network).
class BuiltInWallpapers {
  BuiltInWallpapers._();

  static const String assetPrefix = 'asset:assets/wallpapers/';

  static const List<BuiltInWallpaper> all = <BuiltInWallpaper>[
    BuiltInWallpaper(
      id: 'misty_pine_forest',
      assetPath: 'assets/wallpapers/misty_pine_forest.jpg',
      nameEn: 'Misty Pine Forest',
      nameAr: 'غابة الصنوبر الضبابية',
    ),
    BuiltInWallpaper(
      id: 'golden_desert_dunes',
      assetPath: 'assets/wallpapers/golden_desert_dunes.jpg',
      nameEn: 'Golden Dunes',
      nameAr: 'كثبان الغروب الذهبية',
    ),
    BuiltInWallpaper(
      id: 'alpine_lake_twilight',
      assetPath: 'assets/wallpapers/alpine_lake_twilight.jpg',
      nameEn: 'Alpine Lake Twilight',
      nameAr: 'بحيرة الجبل عند الغسق',
    ),
    BuiltInWallpaper(
      id: 'starry_ocean_night',
      assetPath: 'assets/wallpapers/starry_ocean_night.jpg',
      nameEn: 'Starry Ocean Night',
      nameAr: 'سماء النجوم والمحيط',
    ),
    BuiltInWallpaper(
      id: 'autumn_woodland',
      assetPath: 'assets/wallpapers/autumn_woodland.jpg',
      nameEn: 'Autumn Woodland',
      nameAr: 'أشجار الخريف الدافئة',
    ),
    BuiltInWallpaper(
      id: 'emerald_rain_leaves',
      assetPath: 'assets/wallpapers/emerald_rain_leaves.jpg',
      nameEn: 'Emerald Rain Leaves',
      nameAr: 'أوراق المطر الزمردية',
    ),
  ];
}
