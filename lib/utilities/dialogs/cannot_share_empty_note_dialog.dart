import 'package:first_app/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: "Empty Note",
    content: "You cannot share an empty note",
    optionsBuilder: () => {"OK": null},
  ).then((value) => value ?? false);
}
