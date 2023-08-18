import 'package:first_app/constants/routes.dart';
import 'package:first_app/services/auth/auth_exceptions.dart';
import 'package:first_app/services/auth/auth_service.dart';
import 'package:first_app/services/auth/bloc/auth_bloc.dart';
import 'package:first_app/services/auth/bloc/auth_event.dart';
import 'package:first_app/services/auth/bloc/auth_state.dart';
import 'package:first_app/utilities/dialogs/error_dialog.dart';
import 'package:first_app/utilities/dialogs/loading_dialog.dart';

import 'package:flutter/material.dart';
import 'dart:developer' show log;

import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  CloseDialog? _closeDialog;

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            log('The password provided is too weak.');
            await showErrorDialog(
              context: context,
              text: 'The password provided is too weak.',
            );
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            log('The account already exists for that email.');
            await showErrorDialog(
              context: context,
              text: 'The account already exists for that email.',
            );
          } else if (state.exception is InvalidEmailAuthException) {
            log('The email address is not valid.');
            await showErrorDialog(
              context: context,
              text: 'The email address is not valid.',
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
              context: context,
              text: 'Registering Error',
            );
          } else if (state.exception != null) {
            log(state.exception.toString());
            await showErrorDialog(
              context: context,
              text: "Registering Error",
            );
          }
        }
      },
      child: Scaffold(
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
                    context
                        .read<AuthBloc>()
                        .add(AuthEventRegister(email, password));
                  },
                  child: const Text("Register")),
              TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  },
                  child: const Text("Go to Login Here"))
            ],
          ),
        ),
      ),
    );
  }
}
