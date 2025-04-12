import 'package:flutter/material.dart';
import 'package:tutorial_flutter/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
      context: context,
      title: 'Log out',
      content: 'Are you sure you want to log out?',
      optionsBuilder: () => {
        'Cancel': false,
        'Log out': true,
      },
  ).then(
      (value) => value ?? false, // Wenn der zurückgegebene Wert "null" ist, setze ihn auf false
  );
}