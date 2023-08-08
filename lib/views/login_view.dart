import 'package:firebase_auth/firebase_auth.dart';
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
      body: Column(
        children: [
          TextField(
              decoration: const InputDecoration(hintText: "Email"),
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              controller: _emailController),
          TextField(
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: "Password"),
            controller: _passwordController,
          ),
          TextButton(
              onPressed: () async {
                final email = _emailController.text;
                final password = _passwordController.text;
                try {
                  final userCredential = await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: email, password: password);
                  //log(userCredential.toString());
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/notes',
                    (route) => false,
                  );
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'user-not-found') {
                    log('No user found for that email.');
                  } else if (e.code == 'wrong-password') {
                    log('Wrong password provided for that user.');
                  }
                }
              },
              child: const Text("Login")),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/register',
                (route) => false,
              );
            },
            child: const Text("Register a new account"),
          )
        ],
      ),
    );
  }
}
