import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_flutter/helpers/loading/loading_screen_controller.dart';

class LoadingScreen {
  factory LoadingScreen() => _shared; //Singelton
  static final LoadingScreen _shared = LoadingScreen._sharedInstance();
  LoadingScreen._sharedInstance();

  LoadingScreenController? controller; // Die Variable 'controller' ist vom Typ 'LSC?'.
  // So wird über 'controller' auf die Klasse 'LSC' und somit auf deren Funktionen "Schließen" und "Laden" zugegriffen.

  void show({ // Anzeige der Ladeanzeige.
    required BuildContext context,
    required String text,
}) {
    if (controller?.update(text) ?? false) { // Falls bereits eine Ladeanzeige existiert, wird sie aktualisiert.
      // '??' stellt eine Alternative bereit (in diesem Fall 'false') wenn der "linke Wert" ('c?.u(t)') gleich null ist
      // Wenn 'controller' null ist, dann wird der ganze Ausdruck ('c?.u(t)') zu null
      // Wenn 'controller' nicht null ist, dann wird 'update(text)' verwendet.
      return; // Keine neue Anzeige nötig, wenn eine bereits existiert und aktualisiert werden kann.
    } else {
      controller = showOverlay( // Falls keine Ladeanzeige existiert, wird eine neue Overlay-Anzeige erstellt.
        context: context,
        text: text,
      );
    }
  }

  void hide() {
    controller?.close(); // Schließt die Ladeanzeige, wenn sie existiert.
    controller = null; // Setzt den Controller auf `null`, um anzuzeigen, dass keine Ladeanzeige mehr aktiv ist.
  }

  LoadingScreenController showOverlay({
    required BuildContext context,
    required String text,
  }) {

    final _text = StreamController<String>(); // Erstellt einen StreamController für den Text der Ladeanzeige.
    _text.add(text); // Fügt den initialen Text hinzu.

    final state = Overlay.of(context); // Holt die Overlay-Instanz aus dem aktuellen BuildContext.
    final renderBox = context.findRenderObject() as RenderBox; // Holt die Größe des aktuellen Bildschirms.
    final size = renderBox.size; // Speichert die Größe des Bildschirms.

    final overlay = OverlayEntry ( // OverlayEntry ist der sichtbare Teil des Overlays.
      builder: (context) {
        return Material( // Material-Widget für das Styling der Anzeige.
          color: Colors.black.withAlpha(150), // Halbtransparent schwarzer Hintergrund.
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: size.width * 0.8, // Maximale Breite und Höhe sind relativ zur Bildschirmgröße
                maxHeight: size.width * 0.8,
                minWidth: size.width * 0.5,
              ),
              decoration: BoxDecoration(
                color: Colors.white, // Hintergrundfarbe der Ladeanzeige.
                borderRadius: BorderRadius.circular(10.0), // Abgerundete Ecken.
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Innenabstand der Anzeige.
                child: SingleChildScrollView(
                  child: Column( // Layout der Ladeanzeige (Indikator + Text).
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      StreamBuilder( // Aktualisiert den angezeigten Text, wenn sich der Text im Stream ändert.
                          stream: _text.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                snapshot.data as String, // Zeigt den Text an, der über den Stream gesendet wird.
                                textAlign: TextAlign.center,
                              );
                            } else {
                              return Container(); // Leerer Container, wenn kein Text vorhanden ist.
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        );
      },
    );

    state.insert(overlay); // Fügt das Overlay der UI hinzu, sodass es sichtbar wird.

    return LoadingScreenController( // Gibt den Controller zurück, der es erlaubt, das Overlay zu aktualisieren oder zu schließen.
      close: () {
        _text.close(); // Schließt den Stream, wenn das Overlay geschlossen wird.
        overlay.remove(); // Entfernt das Overlay von der UI.
        return true; // Gibt an, dass das Overlay erfolgreich geschlossen wurde.
      },
      update: (text) {
        _text.add(text); // Aktualisiert den Text im Overlay, wenn der Nutzer neuen Text sendet.
        return true; // Gibt an, dass das Update erfolgreich war.
      },
    );
  }
}