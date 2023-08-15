import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final bool isEmailVerified;
  final String email;
  final String userId;

  const AuthUser({
    required this.isEmailVerified,
    required this.email,
    required this.userId,
  });

  factory AuthUser.fromFirebase(User user) => AuthUser(
        isEmailVerified: user.emailVerified,
        email: user.email!,
        userId: user.uid,
      );
}
