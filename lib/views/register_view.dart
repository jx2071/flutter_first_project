import 'package:first_app/constants/routes.dart';
import 'package:first_app/services/auth/auth_exceptions.dart';
import 'package:first_app/services/auth/auth_service.dart';
import 'package:first_app/utilities/dialogs/error_dialog.dart';

import 'package:flutter/material.dart';
import 'dart:developer' show log;

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(title: const Text("Register")),
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
                    final user = await AuthService.firebase()
                        .createUser(email: email, password: password);
                    log(user.toString());
                    await AuthService.firebase().sendEmailVerification();
                  } on WeakPasswordAuthException {
                    log('The password provided is too weak.');
                    await showErrorDialog(
                      context: context,
                      text: 'The password provided is too weak.',
                    );
                  } on EmailAlreadyInUseAuthException {
                    log('The account already exists for that email.');
                    await showErrorDialog(
                      context: context,
                      text: 'The account already exists for that email.',
                    );
                  } on InvalidEmailAuthException {
                    log('The email address is not valid.');
                    await showErrorDialog(
                      context: context,
                      text: 'The email address is not valid.',
                    );
                  } catch (e) {
                    await showErrorDialog(
                      context: context,
                      text: 'Error: ${e.toString()}',
                    );
                  }
                },
                child: const Text("Register")),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
                    (route) => false,
                  );
                },
                child: const Text("Go to Login Here"))
          ],
        ),
      ),
    );
  }
}
