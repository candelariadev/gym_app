import '../entities/federated_auth_flow.dart';
import '../entities/individual_onboarding.dart';

abstract interface class FederatedAuthRepository {
  Future<FederatedAuthFlow> signIn(String idToken);
  Future<FederatedAuthFlow> completeOnboarding(IndividualOnboarding onboarding);
}
