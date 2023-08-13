import 'package:first_app/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showLogoutDialog({
  required BuildContext context,
}) {
  return showGenericDialog<bool>(
    context: context,
    title: "Logout",
    content: "Are you sure you want to log out?",
    optionsBuilder: () => {
      "Cancel": false,
      "Logout": true,
    },
  ).then((value) => value ?? false);
}
