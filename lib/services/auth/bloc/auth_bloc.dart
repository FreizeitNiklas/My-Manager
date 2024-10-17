import 'package:bloc/bloc.dart';
import 'package:tutorial_flutter/services/auth/bloc/auth_event.dart';
import 'package:tutorial_flutter/services/auth/bloc/auth_state.dart';
import 'package:tutorial_flutter/services/auth/auth_provider.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Der Konstruktor der AuthBloc-Klasse. Initialisiert den Zustand mit `AuthStateLoading`, d.h., der Ladezustand wird zu Beginn angezeigt.
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUninitialized(isLoading: true)) {
    // AuthBloc ist der Konstruktor // (AP p) ist der Paramter des Konstruktors
    // ':' Dies ist eine Initialisierer-Liste.
    // Sie ermöglicht es, dem Konstruktor der Basisklasse Werte zu übergeben, bevor der Konstruktor der abgeleiteten Klasse ausgeführt wird.

    //send email verification
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider
          .sendEmailVerification(); // die Methode 'sEV' des 'AuthProvider' wird aufgerufen
      emit(state); // gibt den aktuellen Zustand weiter.
    });
    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;
      try {
        await provider.createUser(
          // die Methode 'cU' des 'AuthProvider' wird aufgerufen
          email: email,
          password: password,
        );
        await provider.sendEmailVerification();
        emit(const AuthStateNeedsVerification(isLoading: false)); // Der Zustand wird in AuthStateNeedsVerification geändert.
      } on Exception catch (e) {
        //  Falls ein Fehler auftritt, wird der Zustand in AuthStateRegistering geändert, und die Ausnahme wird übergeben.
        emit(AuthStateRegistering(
          exception: e,
          isLoading: false,
        ));
      }
    });
    // initialize
    // Verarbeitung des AuthEventInitialize Ereignisses (initialisieren der Authentifizierung)
    on<AuthEventInitialize>((event, emit) async {
      //event an dieser Stelle quasi "unnötig" / emit wird genutzt um Infos (den State) zu senden
      await provider.initialize(); // Initialisiert den Provider (z.B. Firebase)
      final user =
          provider.currentUser; // Ruft den aktuell eingeloggten Benutzer ab.
      if (user == null) {
        // Es ist kein Benutzer angemeldet.
        emit(
          // emit wird genutzt um über Bloc Zustände zu senden
          const AuthStateLoggedOut(
            // Zustand wird auf 'ASLO' geändert.
            exception: null,
            isLoading: false,
          ), //wo bekomm ich das "auto-formatieren" zum laufen?
        );
        // 'null' wird genutzt um den Zustand eindeutig zu beschreiben
        // 'ASLO' erwartet ein Argument von Typ 'Exception?' -> Es wird also entweder eine 'Exception' oder 'null' übergeben
      } else if (!user.isEmailVerified) {
        // Falls der User nicht verifiziert ist.
        emit(const AuthStateNeedsVerification(isLoading: false));
      } else {
        // Ist der User verifiziert, dann wird der Zustand auf 'ASLI' gesetzt.
        emit(AuthStateLoggedIn(
          user: user,
          isLoading: false,
        ));
      }
    });
    // log in
    on<AuthEventLogIn>((event, emit) async {
      emit(
        const AuthStateLoggedOut(
          exception: null,
          isLoading: true,
          loadingText: 'Please wait while I log you in',
        ),
      );
      await Future.delayed(const Duration(
          seconds:
              3)); // Login dauert 3 Sekunden länger (damit man das "Loading..." sehen kann)
      final email = event
          .email; // Ruft die Anmeldedaten (E-Mail und Passwort) aus dem Event ab
      final password = event.password;
      try {
        final user = await provider.logIn(
          // Versucht, den Benutzer mit den Anmeldedaten einzuloggen.
          email: email,
          password: password,
        );

        if (!user.isEmailVerified) {
          emit(
            const AuthStateLoggedOut(
              exception: null,
              isLoading: false,
            ),
          );
          emit(const AuthStateNeedsVerification(isLoading: false));
        } else {
          emit(
            const AuthStateLoggedOut(
              exception: null,
              isLoading: false,
            ),
          );
          emit(AuthStateLoggedIn(
            user: user,
            isLoading: false,
          ));
        }
      } on Exception catch (e) {
        emit(
          AuthStateLoggedOut(
            exception: e,
            isLoading: false,
          ),
        );
      }
    });

    //   // Hier musste ich den Code anpassen, weil der Fehler sonst nicht gefangen wurde!
    //   emit(AuthStateLoggedIn(user as AuthUser));  // Erfolgreiches Login
    // } on WrongPasswordAuthException catch (_) {
    //   emit(AuthStateLoggedOut(WrongPasswordAuthException()));  // Spezifischer Fehler: Falsches Passwort
    // } on UserNotFoundAuthException catch (_) {
    //   emit(AuthStateLoggedOut(UserNotFoundAuthException()));  // Spezifischer Fehler: Nutzer nicht gefunden
    // } on Exception catch (e) {
    //   emit(AuthStateLoggedOut(e));  // Allgemeiner Fehler
    // }

    // log out
    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logOut();
        emit(
          const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ),
        );
      } on Exception catch (e) {
        emit(
          AuthStateLoggedOut(exception: e, isLoading: false),
        );
      }
    });
  }
}
