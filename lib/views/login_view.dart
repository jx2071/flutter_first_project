import 'package:first_app/constants/routes.dart';
import 'package:first_app/services/auth/auth_exceptions.dart';
import 'package:first_app/services/auth/auth_service.dart';
import 'package:first_app/utilities/dialogs/error_dialog.dart';

import 'package:flutter/material.dart';
import 'dart:developer' show log;

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 50),
            SizedBox(
              width: 300,
              child: TextField(
                  decoration: const InputDecoration(hintText: "Email"),
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController),
            ),
            SizedBox(
              width: 300,
              child: TextField(
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(hintText: "Password"),
                controller: _passwordController,
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
                onPressed: () async {
                  final email = _emailController.text;
                  final password = _passwordController.text;
                  try {
                    final user = await AuthService.firebase().logIn(
                      email: email,
                      password: password,
                    );
                    if (user.isEmailVerified == false ?? true) {
                      await AuthService.firebase().sendEmailVerification();
                      Navigator.of(context).pushNamed(verifyEmailRoute);
                    } else {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        notesRoute,
                        (route) => false,
                      );
                    }
                  } on UserNotFoundAuthException {
                    log('No user found for that email.');
                    await showErrorDialog(
                      context: context,
                      text: 'Email not registered.',
                    );
                  } on WrongPasswordAuthException {
                    log('Wrong password provided for that user.');
                    await showErrorDialog(
                      context: context,
                      text: 'Wrong credentials.',
                    );
                  } catch (e) {
                    await showErrorDialog(
                      context: context,
                      text: e.toString(),
                    );
                  }
                },
                child: const Text("Login")),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  registerRoute,
                  (route) => false,
                );
              },
              child: const Text("Register a new account"),
            )
          ],
        ),
      ),
    );
  }
}
