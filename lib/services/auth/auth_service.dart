import 'package:tutorial_flutter/services/auth/auth_provider.dart';
import 'package:tutorial_flutter/services/auth/auth_user.dart';
import 'package:tutorial_flutter/services/auth/firebase_auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());
  //It returns an instance of AuthService witch is already configured with FirebaseAuthProvider
  //"factory": Its creates an instance of an class and can also return it
  //".firebase": Is the name of the constructor
  //It's initialized AuthService with FirebaseAuthProvider

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) =>
      provider.createUser(
        email: email,
        password: password,
      );

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) =>
      provider.logIn(
        email: email,
        password: password,
      );

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) =>
      provider.sendPasswordReset(toEmail: toEmail);
}
