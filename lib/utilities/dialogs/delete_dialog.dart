import 'package:first_app/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showDeleteDialog({required BuildContext context}) {
  return showGenericDialog(
      context: context,
      title: "Delete",
      content: "Are you sure you want to delete this note?",
      optionsBuilder: () => {
            "Cancel": false,
            "Delete": true,
          }).then((value) => value ?? false);
}
