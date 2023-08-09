import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final bool isEmailVerified;
  final String? email;

  const AuthUser(this.isEmailVerified, this.email);

  factory AuthUser.fromFirebase(User user) => AuthUser(
        user.emailVerified,
        user.email,
      );
}
