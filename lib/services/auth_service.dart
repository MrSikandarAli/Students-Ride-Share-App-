import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Wraps FirebaseAuth + the `users` Firestore collection so the rest
/// of the app never talks to Firebase SDKs directly. This keeps auth
/// logic testable and swappable.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Registers a student with a university-style email/password and
  /// creates their matching Firestore profile document.
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    required String studentId,
    required String university,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = credential.user!.uid;
    final user = UserModel(
      uid: uid,
      fullName: fullName.trim(),
      email: email.trim(),
      studentId: studentId.trim(),
      university: university.trim(),
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(uid).set(user.toMap());
    await credential.user!.updateDisplayName(fullName.trim());
    await credential.user!.sendEmailVerification();

    return user;
  }

  Future<UserModel> login({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return fetchProfile(credential.user!.uid);
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() => _auth.signOut();

  Future<UserModel> fetchProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw Exception('Profile not found for user $uid');
    }
    return UserModel.fromDoc(doc);
  }

  Stream<UserModel> profileStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .where((doc) => doc.exists)
        .map((doc) => UserModel.fromDoc(doc));
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) {
    return _firestore.collection('users').doc(uid).update(data);
  }
}
