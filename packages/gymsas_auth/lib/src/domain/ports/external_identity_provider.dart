abstract interface class ExternalIdentityProvider {
  Future<String> signInWithGoogle();
  Future<String> refreshIdToken();
  Future<void> signOut();
}
