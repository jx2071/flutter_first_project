import 'package:first_app/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showErrorDialog({
  required BuildContext context,
  required String text,
}) {
  return showGenericDialog<void>(
    context: context,
    title: "Error",
    content: text,
    optionsBuilder: () => {
      "OK": null,
    },
  );
}
