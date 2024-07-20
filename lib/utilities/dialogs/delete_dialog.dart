import 'package:flutter/material.dart';
import 'package:tutorial_flutter/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete',
    content: 'Are you sure you want to delete this item?',
    optionsBuilder: () => {
      'Cancel': false,
      'Yes': true,
    },
  ).then(
        (value) => value ?? false, // Wenn zurückgegebener Wert "null" ist, setzt ihn aus false
  );
}