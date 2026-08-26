import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gymsas_auth/gymsas_auth.dart';

class FirebaseGoogleIdentityProvider implements ExternalIdentityProvider {
  FirebaseGoogleIdentityProvider._(this._firebaseAuth, this._googleSignIn);

  static Future<FirebaseGoogleIdentityProvider> initialize({
    FirebaseOptions? options,
    FirebaseAuth? firebaseAuth,
  }) async {
    if (Firebase.apps.isEmpty) await Firebase.initializeApp(options: options);
    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize();
    return FirebaseGoogleIdentityProvider._(
      firebaseAuth ?? FirebaseAuth.instance,
      googleSignIn,
    );
  }

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  @override
  Future<String> signInWithGoogle() async {
    final googleUser = await _googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw StateError('Google did not return an ID token');
    }
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final result = await _firebaseAuth.signInWithCredential(credential);
    final firebaseToken = await result.user?.getIdToken(true);
    if (firebaseToken == null || firebaseToken.isEmpty) {
      throw StateError('Firebase did not return an ID token');
    }
    return firebaseToken;
  }

  @override
  Future<String> refreshIdToken() async {
    final token = await _firebaseAuth.currentUser?.getIdToken(true);
    if (token == null || token.isEmpty) throw StateError('Firebase session is missing');
    return token;
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
  }
}
