import 'package:bloc/bloc.dart';
import 'package:tutorial_flutter/services/auth/auth_user.dart';
import 'package:tutorial_flutter/services/auth/bloc/auth_event.dart';
import 'package:tutorial_flutter/services/auth/bloc/auth_state.dart';
import 'package:tutorial_flutter/services/auth/auth_provider.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Der Konstruktor der AuthBloc-Klasse. Initialisiert den Zustand mit `AuthStateLoading`, d.h., der Ladezustand wird zu Beginn angezeigt.
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading ()) { // AuthBloc ist der Konstruktor // (AP p) ist der Paramter des Konstruktors
    // ':' Dies ist eine Initialisierer-Liste.
    // Sie ermöglicht es, dem Konstruktor der Basisklasse Werte zu übergeben, bevor der Konstruktor der abgeleiteten Klasse ausgeführt wird.

    // initialize
    // Verarbeitung des AuthEventInitialize Ereignisses (initialisieren der Authentifizierung)
    on<AuthEventInitialize>((event, emit) async { //event an dieser Stelle quasi "unnötig" / emit wird genutzt um Infos (den State) zu senden
      await provider.initialize(); // Initialisiert den Provider (z.B. Firebase)
      final user = provider.currentUser; // Ruft den aktuell eingeloggten Benutzer ab.
      if (user == null) {
        emit(const AuthStateLoggedOut()); // emit wird genutzt um über Bloc Zustände zu senden
      } else if (!user.isEmailVerified) {
        emit (const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    });
    // log in
    on<AuthEventLogIn>((event, emit) async {
      emit(const AuthStateLoading()); // Während des Logins wird der Ladezustand angezeigt
      final email = event.email; // Ruft die Anmeldedaten (E-Mail und Passwort) aus dem Event ab
      final password = event.password;
      try {
        final user = provider.logIn( // Versucht, den Benutzer mit den Anmeldedaten einzuloggen.
          email: email,
          password: password,
        );
        emit(AuthStateLoggedIn(user as AuthUser)); //user muss als AuthUser implementiert werden???
      } on Exception catch (e) {
        emit(AuthStateLoginFailure(e));
      }
    });
    // log out
    on<AuthEventLogOut>((event, emit) async {
      try{
        emit(const AuthStateLoading());
        await provider.logOut();
        emit(const AuthStateLoggedOut());
      } on Exception catch (e) {
       emit(AuthStateLogoutFailure(e));
      }
    });
  }
}