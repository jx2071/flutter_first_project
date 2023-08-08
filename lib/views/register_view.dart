import 'package:firebase_auth/firebase_auth.dart';
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
                      .createUserWithEmailAndPassword(
                          email: email, password: password);
                  log(userCredential.toString());
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'weak-password') {
                    log('The password provided is too weak.');
                  } else if (e.code == 'email-already-in-use') {
                    log('The account already exists for that email.');
                  } else if (e.code == 'invalid-email') {
                    log('The email address is not valid.');
                  }
                }
              },
              child: const Text("Register")),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child: const Text("Go to Login Here"))
        ],
      ),
    );
  }
}
