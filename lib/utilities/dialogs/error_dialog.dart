import 'package:flutter/cupertino.dart';
import 'package:tutorial_flutter/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text
) {
  return showGenericDialog(
    context: context,
    title: 'An error occurred',
    content: text,
    optionsBuilder: () => {
      'OK' : null,
    },
  );
}