import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutorial_flutter/services/auth/bloc/auth_bloc.dart';
import 'package:tutorial_flutter/services/auth/bloc/auth_event.dart';
import 'package:tutorial_flutter/services/auth/bloc/auth_state.dart';
import 'package:tutorial_flutter/services/auth/firebase_auth_provider.dart';
import 'package:tutorial_flutter/views/login_view.dart';
import 'package:tutorial_flutter/views/notes/create_update_note_view.dart';
import 'package:tutorial_flutter/views/notes/notes_view.dart';
import 'package:tutorial_flutter/views/register_view.dart';
import 'package:tutorial_flutter/views/verify_email_view.dart';
import 'constants/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Stellt sicher, dass die Widgets-Bindung initialisiert ist (z.B. für die Interaktion mit der Plattform).

  // `runApp` startet die App und rendert das `MaterialApp` Widget.
  runApp(
    MaterialApp(
      title: 'Flutter Demo', // Setzt den Titel der App.
      theme: ThemeData(
        primarySwatch: Colors.blue, // Definiert das allgemeine Farbschema der App.
      ),
      home: BlocProvider<AuthBloc>( // Erstellt eine Instanz von AuthBloc und bindet sie in den Widget-Baum ein, damit alle untergeordneten Widgets auf diese Instanz zugreifen können
        create: (context) => AuthBloc(FirebaseAuthProvider()), // Erstellt eine Instanz von AuthBloc mit einem AuthProvider.
        child: const HomePage() // Das Kind ist die HomePage, die auf den AuthBloc zugreifen kann.
      ),
      routes: {
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(), // Seite zum Erstellen/Aktualisieren einer Notiz.
        // Der context ist eine Referenz, die Flutter benötigt, um zu wissen, wo das aktuelle Widget sich im Baum befindet
        // und welche übergeordneten Informationen und Zustände verfügbar sind.
        // Wenn ein Nutzer die loginRoute aufruft, wird eine neue Instanz von LoginView erzeugt.
        // Der context bezieht sich dabei auf den aktuellen Build-Kontext, also wo genau in der App-Hierarchie diese Route ausgelöst wird.
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Liest den AuthBloc aus dem Kontext und sendet das AuthEventInitialize-Ereignis,
    // um den Authentifizierungsprozess zu initialisieren.
    context.read<AuthBloc>().add(const AuthEventInitialize());
    // Der BlocBuilder wird verwendet, um die Benutzeroberfläche basierend auf dem Zustand des AuthBloc aufzubauen.
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
      } else {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

// // Die `HomePage` ist ein `StatefulWidget`, da sie einen änderbaren Zustand hat.
// class HomePage extends StatefulWidget { // Die HomePage ist ein StatefulWidget, weil sie den Zustand des TextControllers und die dynamische Eingabenänderung durch den Bloc verwaltet.
//   const HomePage({super.key}); // Bedeutet: Rufe den Konstruktor der übergeordneten Klasse auf und übergib den Key-Wert, falls vorhanden
//                                 // Die übergeordnete Klasse ist "StatefulWidget"
//
// // StatefulWidget: Dies ist eine abstrakte Klasse, die beschreibt, wie das Widget aussieht und sich verhält, aber es hält keine Informationen über den Zustand.
// // Es dient als Container für die State-Klasse.
// // State: Dies ist eine Klasse, die den tatsächlichen Zustand eines StatefulWidget verwaltet.
// // Hier implementierst du die Logik, die den Zustand des Widgets ändert und das Widget neu zeichnet, wenn sich dieser Zustand ändert.
//   @override
//   State<HomePage> createState() => _HomePageState(); //cS erstellt eine Instanz einer State-Klasse. Diese Instanz hat die Aufgabe den Zustand (State) des Statefulwidgets (HomePage) zu verwalten.
// }
// // Diese Methode erstellt eine neue Instanz von _HomePageState,
// // Diese Instanz verwaltet den Zustand (State) für das Statefulwidget.
// // In diesem Fall überschreibt createState() die (selbe) Methode der Superklasse (StatefulWidget).
// // Jede Klasse, die von StatefulWidget erbt, muss die Methode createState() überschreiben, um den Zustand (State) zu erzeugen.
//
// class _HomePageState extends State<HomePage> { // _HPS erbt von S<HP> um die Funktionalität des Statefulwidgets zu nutzen und es gleichzeit zu verwalten
//   // Textfeld-Controller, um den eingegebenen Text im `TextField` zu verwalten.
//   late final TextEditingController _controller;
//   // Die Variable _controller wird erst später intialisiert und lässt sich danach nicht mehr verändern (ist für die Verwendung von initState wichtig)
//   // _c ist eine Instanz von TEC. Mit ihr wird der Text verwaltet.
//   // Man erstellt hier eine Instanz, weil ich dieser die Infos gespeichert bleiben, auch wenn das Widget neu aufgerufen wird
//
//   // `initState` wird aufgerufen, wenn das Widget erstellt wird.
//   @override
//   void initState() {
//     _controller = TextEditingController(); // Initialisiert den Text-Controller.
//     super.initState();
//   }
//
//   // `dispose` wird aufgerufen, wenn das Widget entfernt wird, um den Controller zu bereinigen.
//   @override
//   void dispose() {
//     _controller.dispose(); // Gibt die Ressourcen des Controllers frei.
//     super.dispose();
//   }
//
//   // Die `build`-Methode beschreibt den Aufbau des UI.
//   @override
//   // Mit "build" wird visuelle Darstellung definiert -> Wird aufgerufen (neu gebaut), wenn sich der Zustand des StatefulWidgets ändert
//   // "context" enthält Informationen über den aktuellen Build-Prozess und die Position des Widgets im Widget-Baum.
//   // "BuildContext" ermöglicht den Zugriff auf übergeordnete Widgets und Daten
//   Widget build(BuildContext context) {
//     // Bloc trennt das UI von der Logik.
//     // States beschreiben den Zustand der App und werden von Bloc an das UI gesendet.
//     // Events sind Eingaben, welche vom UI über Bloc an die App geschickt werden (z.B. "Button gedrückt").
//     // `BlocProvider` stellt dem Widget-Baum den `CounterBloc` zur Verfügung.
//     return BlocProvider(
//       create: (context) => CounterBloc(), // Erstellt den `CounterBloc`, der für die Zustandsverwaltung zuständig ist.
//       // `child` definiert den Teil der Benutzeroberfläche, der vom `BlocProvider` beeinflusst wird.
//       child: Scaffold( // Scaffold stellt die Grundstruktur für die Seite bereit, wie eine App-Leiste und den Body.
//         appBar: AppBar(
//           title: const Text('Testing Bloc'), // Der Titel in der App-Leiste, der "Testing Bloc" anzeigt.
//         ),
//         // `BlocConsumer` kombiniert zwei Funktionen: `BlocListener` und `BlocBuilder`.
//         // Es wird verwendet, um auf Zustandsänderungen im `CounterBloc` zu reagieren.
//         body: BlocConsumer<CounterBloc, CounterState>(
//           // `listener` reagiert auf Zustandsänderungen und führt Aktionen aus (wie z.B. das leeren eines Textfeldes).
//           listener: (context, state) {
//             _controller.clear(); // Leert das Textfeld, wenn der Zustand sich ändert.
//           },
//           // `builder` wird verwendet, um die UI basierend auf dem aktuellen Zustand des Bloc neu zu zeichnen.
//           // Der `builder` gibt ein Widget zurück, das die UI für den aktuellen Zustand darstellt.
//           builder: (context, state) {
//             // Prüft ob 'state' gleich 'CSIN'
//             // Wenn true dann wird 'state' an 'iV' übergeben
//             // Mit 'state.iV' rufe ich aus 'state' nur die für 'iV' nötigen Werte ab
//             // Falls false wird '' übergeben
//             final invalidValue = (state is CounterStateInvalidNumber) ? state.invalidValue : '';
//             // Baut die Benutzeroberfläche.
//             return Column(
//               children: [
//                 // Zeigt den aktuellen Zählerwert an.
//                 Text('current value => ${state.value}'),
//                 // Zeigt eine Fehlermeldung an, wenn eine ungültige Zahl eingegeben wurde.
//                 Visibility( // 'Visibility' steuert ob etwas angezeigt wird oder nicht.
//                   child: Text('Invalid input: $invalidValue'),
//                   visible: state is CounterStateInvalidNumber, // Sichtbar, wenn der Zustand ungültig ist.
//                 ),
//                 // Textfeld für die Eingabe einer Zahl.
//                 TextField(
//                   controller: _controller, // Der TextEditingController, der das Textfeld steuert.
//                   decoration: const InputDecoration(
//                     hintText: 'Enter a number here', // Platzhalter-Text.
//                   ),
//                   keyboardType: TextInputType.number, // Tastaturlayout für die Eingabe von Zahlen.
//                 ),
//                 // Zwei Schaltflächen, um den Zählerwert zu erhöhen oder zu verringern.
//                 Row(
//                   children: [
//                     TextButton(
//                       onPressed: () {
//                         // Sendet das `DecrementEvent` an den `CounterBloc` mit dem eingegebenen Wert.
//                         context.read<CounterBloc>().add(DecrementEvent(_controller.text));
//                       },
//                       child: const Text('-'), // Text für die Schaltfläche.
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         // Sendet das `IncrementEvent` an den `CounterBloc` mit dem eingegebenen Wert.
//                         context.read<CounterBloc>().add(IncrementEvent(_controller.text));
//                       },
//                       child: const Text('+'), // Text für die Schaltfläche.
//                     ),
//                   ],
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
// // Abstrakte Klasse `CounterState`, die den Basiszustand für den Zähler darstellt.
// @immutable
// abstract class CounterState {
//   final int value; // Speichert den eingegebenen Wert.
//   const CounterState(this.value); // Konstruktor, der den Zählerwert initialisiert.
// }
//
// // Zustand, wenn die Eingabe gültig ist.
// class CounterStateValid extends CounterState {
//   const CounterStateValid(int value) : super(value); // Vererbt den Wert an die Basisklasse `CounterState`.
// }
//
// // Zustand, wenn eine ungültige Zahl eingegeben wurde.
// class CounterStateInvalidNumber extends CounterState {
//   final String invalidValue; // Speichert den ungültigen eingegebenen Wert.
//
//   const CounterStateInvalidNumber({
//     required this.invalidValue, // Erforderliche Übergabe des ungültigen Wertes.
//     required int previousValue, // Der vorherige gültige Zählerwert.
//   }) : super(previousValue); // Vererbt den vorherigen Wert an `CounterState`.
// }
//
// // Abstrakte Klasse `CounterEvent`, die als Basis für Ereignisse dient.
// @immutable
// abstract class CounterEvent {
//   final String value; // Enthält den Wert, der durch das Ereignis verarbeitet wird.
//   const CounterEvent(this.value); // Konstruktor, der den eingegebenen Text-Wert initialisiert.
// }
//
// // Ereignis, das eine Erhöhung des Zählers darstellt.
// class IncrementEvent extends CounterEvent {
//   const IncrementEvent(String value) : super(value); // Erbt den eingegebenen Wert von der Basisklasse `CounterEvent`.
// }
//
// // Ereignis, das eine Verringerung des Zählers darstellt.
// class DecrementEvent extends CounterEvent {
//   const DecrementEvent(String value) : super(value); // Erbt den eingegebenen Wert von der Basisklasse `CounterEvent`.
// }
//
// // Bloc-Klasse, die die Logik des Zählers verwaltet.
// class CounterBloc extends Bloc<CounterEvent, CounterState> {
//   CounterBloc() : super(const CounterStateValid(0)) { // Initialisiert mit einem Zählerwert von 0.
//
//     // Verarbeitung des `IncrementEvent`.
//     on<IncrementEvent>((event, emit) {
//       final integer = int.tryParse(event.value); // Versucht, den eingegebenen Text in eine Zahl umzuwandeln.
//       if (integer == null) {
//         // Wenn die Eingabe keine gültige Zahl ist, wird der Zustand `CounterStateInvalidNumber` mit dem ungültigen Wert gesendet.
//         emit(
//           CounterStateInvalidNumber(
//             invalidValue: event.value, // Der ungültige eingegebene Text.
//             previousValue: state.value, // Der vorherige gültige Zählerwert.
//           ),
//         );
//       } else {
//         // Wenn die Eingabe gültig ist, wird der `CounterStateValid` Zustand mit dem neuen Zählerwert gesendet.
//         emit(CounterStateValid(state.value + integer));
//       }
//     });
//
//     // Verarbeitung des `DecrementEvent`.
//     on<DecrementEvent>((event, emit) {
//       final integer = int.tryParse(event.value); // Versucht, den eingegebenen Text in eine Zahl umzuwandeln.
//       if (integer == null) {
//         // Wenn die Eingabe ungültig ist, wird der `CounterStateInvalidNumber` Zustand gesendet.
//         emit(
//           CounterStateInvalidNumber(
//             invalidValue: event.value,
//             previousValue: state.value,
//           ),
//         );
//       } else {
//         // Wenn die Eingabe gültig ist, wird der `CounterStateValid` Zustand mit dem neuen Zählerwert gesendet.
//         emit(CounterStateValid(state.value - integer));
//       }
//     });
//   }
// }
