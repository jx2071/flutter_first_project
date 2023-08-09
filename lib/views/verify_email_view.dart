import 'package:first_app/constants/routes.dart';
import 'package:first_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class VerifyEmailView extends StatelessWidget {
  const VerifyEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: Center(
        child: Column(children: [
          const SizedBox(height: 50),
          const Text('We\'ve sent an email to your email address.'),
          const SizedBox(height: 12),
          const Text('If you don\'t see the email,'),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().sendEmailVerification();
            },
            child: const Text("Click to resend email verification."),
          ),
          TextButton(
              onPressed: () async {
                await AuthService.firebase().logOut();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginRoute, (route) => false);
              },
              child: const Text("Verified? Go to Sign In")),
        ]),
      ),
    );
  }
}
