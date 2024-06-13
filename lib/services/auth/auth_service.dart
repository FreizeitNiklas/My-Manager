import 'auth_provider.dart';
import 'auth_user.dart';

class AuthService implements AuthProvider{
  final AuthProvider provider;
  const AuthService(this.provider);

  @override
  Future<dynamic> createUser({
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
  Future<dynamic> logIn({
    required String email,
    required String password,
  }) =>
      provider.logIn(
          email: email,
          password: password,
      );

  @override
  Future<void> logout() => provider.logout();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();
}
