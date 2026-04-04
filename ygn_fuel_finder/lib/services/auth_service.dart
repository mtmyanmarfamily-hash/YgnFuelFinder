import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseDatabase _db = FirebaseDatabase.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static User? get currentUser => _auth.currentUser;
  static bool get isSignedIn => _auth.currentUser != null;
  static bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;
  static String get displayName => _auth.currentUser?.displayName ?? 'အသုံးပြုသူ';
  static String get email => _auth.currentUser?.email ?? '';
  static String? get photoUrl => _auth.currentUser?.photoURL;

  // Email ကို Firebase key အဖြစ် convert (. @ → _)
  static String _emailToKey(String email) =>
      email.toLowerCase().replaceAll('.', '_').replaceAll('@', '_');

  // Admin role စစ်ဆေး
  static Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return false;
    try {
      final key = _emailToKey(user.email!);
      final snap = await _db.ref('roles/$key/role').get();
      return snap.value == 'admin';
    } catch (_) {
      return false;
    }
  }

  // Admin role stream (real-time)
  static Stream<bool> adminStream() {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      return Stream.value(false);
    }
    final key = _emailToKey(user.email!);
    return _db.ref('roles/$key/role').onValue.map(
        (e) => e.snapshot.value == 'admin');
  }

  // Google Sign-In — throws exception on failure so UI can show error
  static Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // user cancelled
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  static Future<void> signInAnonymously() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  static Stream<User?> get authStateChanges => _auth.authStateChanges();
}
