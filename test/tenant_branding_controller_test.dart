import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/branding/tenant_branding_controller.dart';
import 'package:gymsas_api_client/gymsas_api_client.dart';

void main() {
  test('applies branding only to the current tenant and resets on logout', () async {
    final client = _FakeGraphQlClient();
    ({String ownerId, String accessToken})? session = (ownerId: 'tenant-a', accessToken: 'token-a');
    final controller = TenantBrandingController(client: client, session: () => session);

    await controller.accountChanged();
    expect(controller.branding.brandName, 'Arena Norte');
    expect(controller.branding.assets.logoUrl, 'https://cdn.example/logo.png');

    session = null;
    await controller.accountChanged();
    expect(controller.branding, same(TenantBranding.defaults));
    controller.dispose();
  });
}

class _FakeGraphQlClient implements GraphQlClient {
  @override
  Future<Map<String, dynamic>> execute({
    required String document,
    Map<String, dynamic> variables = const {},
    String? accessToken,
  }) async => {
    'tenantBranding': {
      'brandName': 'Arena Norte',
      'palette': {
        'primary': '#112233', 'secondary': '#223344', 'accent': '#334455',
        'background': '#F1F2F3', 'surface': '#FFFFFF', 'textPrimary': '#101010',
        'textSecondary': '#505050', 'border': '#CCCCCC',
      },
      'assets': {'logoUrl': 'https://cdn.example/logo.png'},
    },
  };

  @override
  void close() {}
}
