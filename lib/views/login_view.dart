import 'package:first_app/constants/routes.dart';
import 'package:first_app/services/auth/auth_exceptions.dart';
import 'package:first_app/services/auth/bloc/auth_bloc.dart';
import 'package:first_app/services/auth/bloc/auth_event.dart';
import 'package:first_app/services/auth/bloc/auth_state.dart';
import 'package:first_app/utilities/dialogs/error_dialog.dart';
import 'package:first_app/utilities/dialogs/loading_dialog.dart';

import 'dart:developer' show log;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
        if (state is AuthStateLoggedOut) {
          final closeDialog = _closeDialog;
          if (!state.isLoading && closeDialog != null) {
            closeDialog();
            _closeDialog = null;
          }
          if (state.isLoading && closeDialog == null) {
            _closeDialog =
                showLoadingDialog(context: context, text: "Loading...");
          }

          if (state.exception is UserNotFoundAuthException) {
            log('No user found for that email.');
            await showErrorDialog(
              context: context,
              text: 'Email not registered.',
            );
          } else if (state.exception is WrongPasswordAuthException) {
            log('Wrong Email/Password provided for that user.');
            await showErrorDialog(
              context: context,
              text: 'Wrong credentials.',
            );
          } else if (state.exception is GenericAuthException) {
            log(state.exception.toString());
            await showErrorDialog(
              context: context,
              text: "Authentication Error",
            );
          } else if (state.exception != null) {
            log(state.exception.toString());
            await showErrorDialog(
              context: context,
              text: "Authentication Error",
            );
          }
        }
      },
      child: Scaffold(
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
                    context
                        .read<AuthBloc>()
                        .add(AuthEventLogIn(email, password));
                  },
                  child: const Text("Login")),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventGoRegister());
                },
                child: const Text("Register a new account"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
