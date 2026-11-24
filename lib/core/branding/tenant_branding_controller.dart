import 'package:flutter/material.dart';
import 'package:gymsas_api_client/gymsas_api_client.dart';
import 'package:gymsas_design_system/gymsas_design_system.dart';

class TenantBranding {
  const TenantBranding({
    required this.brandName,
    required this.palette,
    required this.assets,
  });

  final String brandName;
  final TenantBrandPalette palette;
  final TenantBrandAssets assets;

  static const defaults = TenantBranding(
    brandName: 'GymSAS',
    palette: TenantBrandPalette(
      primary: '#5B5CF6',
      secondary: '#7B7CFF',
      accent: '#D9FF43',
      background: '#FFFFFF',
      surface: '#FFFFFF',
      textPrimary: '#101010',
      textSecondary: '#72727A',
      border: '#E9E9EF',
    ),
    assets: TenantBrandAssets(),
  );

  factory TenantBranding.fromJson(Map<String, dynamic> json) {
    return TenantBranding(
      brandName: json['brandName'] as String? ?? defaults.brandName,
      palette: TenantBrandPalette.fromJson(
        json['palette'] as Map<String, dynamic>? ?? const {},
      ),
      assets: TenantBrandAssets.fromJson(
        json['assets'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  AppColors toAppColors() => AppColors(
    primary: palette.color(palette.primary, AppColors.defaultPalette.primary),
    secondary: palette.color(
      palette.secondary,
      AppColors.defaultPalette.secondary,
    ),
    background: palette.color(
      palette.background,
      AppColors.defaultPalette.background,
    ),
    surface: palette.color(palette.surface, AppColors.defaultPalette.surface),
    textPrimary: palette.color(
      palette.textPrimary,
      AppColors.defaultPalette.textPrimary,
    ),
    textSecondary: palette.color(
      palette.textSecondary,
      AppColors.defaultPalette.textSecondary,
    ),
    border: palette.color(palette.border, AppColors.defaultPalette.border),
    error: AppColors.defaultPalette.error,
    success: palette.color(palette.secondary, AppColors.defaultPalette.success),
  );
}

class TenantBrandPalette {
  const TenantBrandPalette({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
  });

  final String primary,
      secondary,
      accent,
      background,
      surface,
      textPrimary,
      textSecondary,
      border;

  factory TenantBrandPalette.fromJson(Map<String, dynamic> json) {
    const fallback = TenantBranding.defaults;
    String read(String key, String value) => json[key] as String? ?? value;
    return TenantBrandPalette(
      primary: read('primary', fallback.palette.primary),
      secondary: read('secondary', fallback.palette.secondary),
      accent: read('accent', fallback.palette.accent),
      background: read('background', fallback.palette.background),
      surface: read('surface', fallback.palette.surface),
      textPrimary: read('textPrimary', fallback.palette.textPrimary),
      textSecondary: read('textSecondary', fallback.palette.textSecondary),
      border: read('border', fallback.palette.border),
    );
  }

  Color color(String source, Color fallback) {
    final match = RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(source);
    return match
        ? Color(int.parse('FF${source.substring(1)}', radix: 16))
        : fallback;
  }
}

class TenantBrandAssets {
  const TenantBrandAssets({
    this.logoUrl,
    this.faviconUrl,
    this.loginBackgroundUrl,
    this.dashboardHeroUrl,
  });
  final String? logoUrl, faviconUrl, loginBackgroundUrl, dashboardHeroUrl;

  factory TenantBrandAssets.fromJson(Map<String, dynamic> json) =>
      TenantBrandAssets(
        logoUrl: json['logoUrl'] as String?,
        faviconUrl: json['faviconUrl'] as String?,
        loginBackgroundUrl: json['loginBackgroundUrl'] as String?,
        dashboardHeroUrl: json['dashboardHeroUrl'] as String?,
      );
}

class TenantBrandingController extends ChangeNotifier {
  TenantBrandingController({
    required GraphQlClient client,
    required this.session,
  }) : _client = client;
  final GraphQlClient _client;
  final ({String ownerId, String accessToken})? Function() session;
  TenantBranding _branding = TenantBranding.defaults;
  String? _loadedOwner;
  bool _disposed = false;

  TenantBranding get branding => _branding;

  Future<void> accountChanged() async {
    final current = session();
    if (current == null) {
      _loadedOwner = null;
      _set(TenantBranding.defaults);
      return;
    }
    if (_loadedOwner == current.ownerId) return;
    _loadedOwner = current.ownerId;
    _set(TenantBranding.defaults);
    try {
      final data = await _client.execute(
        document: r'''query TenantBranding {
          tenantBranding {
            brandName
            palette { primary secondary accent background surface textPrimary textSecondary border }
            assets { logoUrl faviconUrl loginBackgroundUrl dashboardHeroUrl }
          }
        }''',
        accessToken: current.accessToken,
      );
      if (_loadedOwner != current.ownerId) return;
      final value = data['tenantBranding'];
      if (value is Map<String, dynamic>) _set(TenantBranding.fromJson(value));
    } on Object {
      if (_loadedOwner == current.ownerId) _set(TenantBranding.defaults);
    }
  }

  void _set(TenantBranding value) {
    _branding = value;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _client.close();
    super.dispose();
  }
}
