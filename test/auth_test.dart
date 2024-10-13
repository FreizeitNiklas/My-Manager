import 'package:test/test.dart';
import 'package:tutorial_flutter/services/auth/auth_exceptions.dart';
import 'package:tutorial_flutter/services/auth/auth_provider.dart';
import 'package:tutorial_flutter/services/auth/auth_user.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider(); //"MAP" simuliert das Verhalten eines echten Authetifizierungsanbieters
    test('Should not be initialized to begin with', () {
      expect(provider.isInitialized, false);
    }); //Überprüft, ob der Authentifizierungsanbieter anfänglich nicht initialisiert ist.

    test('Cannot log out if not initialized', () {
      expect(
        provider.logout(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    }); //Überprüft, ob ein NotInitializedException ausgelöst wird, wenn versucht wird, sich ohne vorherige Initialisierung abzumelden.

    test('Should be able to be initialized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }); //Überprüft, ob der Authentifizierungsanbieter erfolgreich initialisiert werden kann.

    test('User should be null after initialization', () {
      expect(provider.currentUser, null);
    }); //Überprüft, ob der aktuelle Benutzer nach der Initialisierung null ist.

    test(
      'Should be able to initialize in less than 2 seconds',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    ); //Überprüft, ob der Authentifizierungsanbieter in weniger als 2 Sekunden initialisiert werden kann.

    test('Create user should delegate to logIn function', () async {
      final badEmailUser = provider.createUser(
        email: 'foo@bar.com',
        password: 'anypassword',
      );
      
      expect(badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final badPasswordUser = provider.createUser(
          email: 'someone@bar.com',
          password: 'foobar',
      );
      expect(badPasswordUser,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));

      final user = await provider.createUser(
        email: 'foo',
        password: 'bar',
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });
    // Überprüft die Benutzererstellung und delegiert die Logik an die logIn-Funktion.
    // Testet verschiedene Fehlerszenarien und die erfolgreiche Benutzererstellung.

    test('Logged in user should be able to get verified', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    }); //Überprüft, ob ein angemeldeter Benutzer seine E-Mail verifizieren kann.

    test('Should be able to log out and log in again', () async {
      await provider.logout();
      await provider.logIn(
          email: 'email',
          password: 'password',
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  }); //Überprüft, ob ein Benutzer sich abmelden und erneut anmelden kann.
}

class NotInitializedException implements Exception {}
//Definiert eine benutzerdefinierte Ausnahme, die ausgelöst wird, wenn Operationen vor der Initialisierung ausgeführt werden.

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async{
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'foobar') throw WrongPasswordAuthException();
    const user = AuthUser(
      id: 'my_id',
      isEmailVerified: false,
      email: 'foo@bar.com',
    );
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logout() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(
      id: 'my_id',
      isEmailVerified: true,
      email: 'foo@bar.com',
    );
    _user = newUser;
  }
}
//Attribute:
// _user: Speichert den aktuellen Benutzer.
// _isInitialized: Gibt an, ob der Anbieter initialisiert ist.
//
// Methoden:
// createUser: Erstellt einen Benutzer und meldet ihn an.
// currentUser: Gibt den aktuellen Benutzer zurück.
// initialize: Initialisiert den Anbieter.
// logIn: Meldet einen Benutzer an.
// logout: Meldet den aktuellen Benutzer ab.
// sendEmailVerification: Sendet eine E-Mail-Verifizierung.
// Dieser Code demonstriert, wie Unit-Tests verwendet werden können,
// um verschiedene Aspekte der Authentifizierungslogik zu überprüfen,
// einschließlich Initialisierung, Anmeldung, Abmeldung und Verifizierung.