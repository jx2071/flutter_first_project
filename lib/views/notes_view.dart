import 'package:first_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

import 'package:first_app/constants/routes.dart';
import 'package:first_app/enums.dart';

import 'dart:developer' show log;

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  final user = AuthService.firebase().currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (action) async {
              switch (action) {
                case MenuAction.logout:
                  final logout = await showLogoutDialog(context);
                  log(logout.toString());
                  if (logout) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (route) => false,
                    );
                  }
                  break;
                default:
                  log('Unknown action: $action');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<MenuAction>(
                value: MenuAction.settings,
                child: Text('Settings'),
              ),
              const PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                child: Text('Logout'),
              )
            ],
          )
        ],
      ),
      body: Center(
          child: Column(
        children: [
          const Text('Welcome to the notes app!'),
          Text('${user?.email}'),
        ],
      )),
    );
  }
}

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Sign out"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text("Sign out"),
          ),
        ],
      );
    },
  ).then(
    (value) => value ?? false,
  );
}
