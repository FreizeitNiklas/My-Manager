import 'package:flutter/cupertino.dart';
import 'package:tutorial_flutter/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Password Reset',
    content:
        'We have now sent you a password reset link. Please check your email for more information.',
    optionsBuilder: () => { // Verwendung einer anonymen Funktion, welche eine Map zurückgibt.
      'OK': null, // Beim klicken auf "OK" passiert nichts ('null').
    },
  );
}
